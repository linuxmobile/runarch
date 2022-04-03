#!/bin/bash

title="linuxmobile's rice setup script"
prefix="[\033[;32m*\033[0m]"

banner() {
  printf "%s\n" \
    '
   @@@@@@@   @@@@@@  @@@@@@@ @@@@@@@@ @@@ @@@      @@@@@@@@  @@@@@@
   @@!  @@@ @@!  @@@   @@!   @@!      @@! @@!      @@!      !@@    
   @!@  !@! @!@  !@!   @!!   @!!!:!   !!@ @!!      @!!!:!    !@@!! 
   !!:  !!! !!:  !!!   !!:   !!:      !!: !!:      !!:          !:!
   :: :  :   : :. :     :     :       :   : ::.: : : :: ::: ::.: : 
      '
}

installParu() {
    clear
    
    sleep 1
    echo -e "$prefix Install paru as AUR helper..."
    echo -e "$prefix Installing paru..."
    
	if [[ -e /usr/bin/paru ]]; then
	paru -Syu
	else
        git clone https://aur.archlinux.org/paru.git $HOME/Downloads/.installer
        cd $HOME/Downloads/.installer/ && makepkg -si
	fi
    
    echo -e "$prefix Paru installed!"
    sleep 0.7
}

downloadDependencies() {
    if grep "Arch\|Artix\|EndeavourOS\|Manjaro" /etc/*-release; then
        clear 
        echo -e "$prefix Running an system update..."
        sudo pacman --noconfirm -Syu

        mkdir -p $HOME/Downloads/.installer
        sleep 0.5
        clear

        if [[ -e /usr/bin/paru ]]; then
            echo -e "$prefix paru detected. Installing dependencies..."
            paru -S python ffmpeg pipewire pipewire-alsa pipewire-pulse alsa-utils inotify-tools  \
            thunar thunar-archive-plugin thunar-volman ffmpegthumbnailer tumbler w3m neovim       \
            viewnior mpv htop lxappearance picom-jonaburg-fix rofi rsync pavucontrol awesome-git  \
            ranger python-pip noto-fonts noto-fonts-emoji noto-fonts-cjk imlib2 fzf todo-bin      \
            exa bat file-roller gvfs gvfs-mtp htop imlib2 xclip alsa-utils alsa-tools xclip       \
            xorg-xsetroot ytfzfim cava  xdg-user-dirs mpd mpc mpdris2 ncmpcpp playerctl xdotool   \
            ueberzug pacman-contrib
        elif [[ -e /usr/bin/yay ]]; then
            echo -e "$prefix yay detected. Installing dependencies..."
            yay -S python ffmpeg pipewire pipewire-alsa pipewire-pulse alsa-utils inotify-tools  \
            thunar thunar-archive-plugin thunar-volman ffmpegthumbnailer tumbler w3m neovim       \
            viewnior mpv htop lxappearance picom-jonaburg-fix rofi rsync pavucontrol awesome-git  \
            ranger python-pip noto-fonts noto-fonts-emoji noto-fonts-cjk imlib2 fzf todo-bin      \
            exa bat file-roller gvfs gvfs-mtp htop imlib2 xclip alsa-utils alsa-tools xclip       \
            xorg-xsetroot ytfzfim cava  xdg-user-dirs mpd mpc mpdris2 ncmpcpp playerctl xdotool   \
            ueberzug pacman-contrib
        else
            # Line from https://github.com/Axarva/dotfiles-2.0/blob/9f0a71d7b23e1213383885f2ec641da48eb01681/install-on-arch.sh#L67
            read -r -p "Would you like to install paru? [Y/n]: " paru
            sleep 1.0

            case $paru in
                [yY][*])
                    git clone https://aur.archlinux.org/paru.git $HOME/Downloads/.installer
                    (cd $HOME/Downloads/.installer && makepkg -si)

                    echo -e "$prefix paru installed. Installing dependencies..."
                    paru -S python ffmpeg pipewire pipewire-alsa pipewire-pulse alsa-utils inotify-tools  \
                    thunar thunar-archive-plugin thunar-volman ffmpegthumbnailer tumbler w3m neovim       \
                    viewnior mpv htop lxappearance picom-jonaburg-fix rofi rsync pavucontrol awesome-git  \
                    ranger python-pip noto-fonts noto-fonts-emoji noto-fonts-cjk imlib2 fzf todo-bin      \
                    exa bat file-roller gvfs gvfs-mtp htop imlib2 xclip alsa-utils alsa-tools xclip       \
                    xorg-xsetroot ytfzfim cava  xdg-user-dirs mpd mpc mpdris2 ncmpcpp playerctl xdotool   \
                    ueberzug pacman-contrib 
                    ;;
                [nN])
                    echo -e "$prefix Okay. Will not install paru."
                    ;;
            esac 
        fi

        sleep 1
    else
        clear
        echo -e "$prefix Not on a Arch based system. Failed to download dependencies. Please manually install it."

        sleep 1
    fi
}

installZSH() {
    clear
    
    sleep 1
    echo -e "$prefix Install Oh-My-Zsh..."
    echo -e "$prefix If this don't work, delete this posix."
    	    if [[ -e $HOME/.oh-my-zsh/ ]]; then
	    clear
	    else
            cd $HOME/
            sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	    fi
        
    echo -e "$prefix Oh-My-Zsh installed!"
    sleep 0.7
}

clonePlugins() {
    clear
    
    sleep 1
    echo -e "$prefix Install Oh-My-Zsh plugins..."
    echo -e "$prefix If this don't work, delete this posix too."
    
        git clone --depth 1 https://github.com/zdharma-continuum/fast-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/fast-syntax-highlighting
        git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions.git $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
        git clone --depth 1 https://github.com/zsh-users/zsh-completions.git $HOME/.oh-my-zsh/custom/plugins/zsh-completions
    
    echo -e "$prefix Oh-My-Zsh plugins installed!"
    sleep 0.7
}

installNerdFonts() {
    clear
    
    sleep 1
    echo -e "$prefix Downloading Nerd Fonts..."
    echo -e "$prefix If this don't work, delete this posix!"
    
        mkdir -p $HOME/Downloads/nerdfonts/
        cd $HOME/Downloads/
        wget https://github.com/ryanoasis/nerd-fonts/releases/download/2.2.0-RC/CascadiaCode.zip
        wget https://github.com/ryanoasis/nerd-fonts/releases/download/2.2.0-RC/Iosevka.zip
        wget https://github.com/ryanoasis/nerd-fonts/releases/download/2.2.0-RC/JetBrainsMono.zip
        unzip '*.zip' -d $HOME/Downloads/nerdfonts/
        rm -rf *.zip
    
    echo -e "$prefix nerdfonts downloaded!"
    sleep 0.7
}

copyFonts() {
    clear
    
    sleep 1
    echo -e "$prefix Copying fonts..."
    echo -e "$prefix If this don't work, delete this posix."
    
        sudo cp -R $HOME/Downloads/nerdfonts/ /usr/share/fonts/
    
    echo -e "$prefix nerd fonts installed!"
    sleep 0.7
}

copyFiles() {
    clear
    
    sleep 1
    echo -e "$prefix Syncing files..."
    echo -e "$prefix Will make a sync if dwm, config and scripts doesn't exists."

        cd $HOME/Documents/
        git clone --depth 1 https://github.com/rxyhn/dotfiles.git
        cd dotfiles
        cp -r config/* ~/.config/
        cp -r bin/* ~/.local/bin/
        cp -r misc/. ~/
    echo -e "$prefix Synced all configs files!"
    sleep 0.7

        cd $HOME/lnxdwm/ && sudo make install

    echo -e "$prefix Make DWM magic!"
    sleep 0.7

        cd $HOME/st/ && sudo make install

    echo -e "$prefix Make ST happen!"

    sleep 0.7
    echo -e "$prefix Synced files successfully."
    sleep 1.3
}

preFlight() {
    if grep "Arch\|Artix\|EndeavourOS\|Manjaro" /etc/*-release; then
        if [[ -e "/usr/bin/whiptail" ]]; then
            echo -e "$prefix whiptail detected. Continuing..."
        else
            echo -e "$prefix whiptail not detected. Installing..."
            sudo pacman -S --noconfirm libnewt
        fi
    else
        clear
        echo -e "$prefix Not on a Arch based system. Please install whiptail/libnewt manually."
    fi
}

finalizeChanges() {
    clear
    echo -e "$prefix Refreshing font cache..."
    fc-cache -rv

    clear
    sleep 1.3

    clear
    echo -e "$prefix Finalizing changes..."
    sleep 3
    clear
}

fuckUser() {
    clear
    echo -e "$prefix An error occured. Exiting."
    exit
}

notice() {
    whiptail --title "$title" \
        --no-button "Exit" --yes-button "Continue" \
        --yesno "This script is experimental! I recommend manually copying the files and installing the dependencies manually. Would you like to continue?" 10 75
}

welcome() {
    whiptail --title "$title" \
        --no-button "Exit" --yes-button "Continue" \
        --yesno "This process will download the needed dependencies and copy the config files to $HOME/.config. Would you like to continue?" 10 70
}

success() {
    # Remove the custom directory made by the script
    rm -rf $HOME/Downloads/.installer
    rm -rf $HOME/paru

    whiptail --title "$title" \
        --msgbox "Setup success. Please reboot xorg if you are on an active session." 10 60
}

echo -e "$prefix Starting setup script..."
sleep 0.5

# Check if whiptail is installed
preFlight
sleep 1

# Prompt notice
notice || fuckUser

# Prompt user the welcome dialog
welcome || fuckUser

# Fancy banner
banner

# Install paru
installParu

# Download dependencies
downloadDependencies

# Install Zsh and Oh-My-Zsh
installZSH

# Clone Oh-My-Zsh plugins
clonePlugins

# Install Nerdfonts
installNerdFonts

# Copying nerdfonts
copyFonts

# Copy files from the repo to $HOME/.config
copyFiles

# Restart everything lol
finalizeChanges

# Show the success dialog when everything is fine
success && clear
