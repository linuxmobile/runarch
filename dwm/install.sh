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

downloadDependencies() {
    if grep "Arch\|Artix\|EndeavourOS\|Manjaro" /etc/*-release; then
        clear 
        echo -e "$prefix Running an system update..."
        sudo pacman --noconfirm -Syu

        mkdir -p $HOME/.setup-scripto
        sleep 0.5
        clear

        if [[ -e /usr/bin/paru ]]; then
            echo -e "$prefix paru detected. Installing dependencies..."
            paru -S python ffmpeg pipewire pipewire-alsa pipewire-pulse alsa-utils dunst       \
            thunar thunar-archive-plugin thunar-volman ffmpegthumbnailer tumbler w3m neovim    \
            viewnior mpv htop lxappearance picom-jonaburg-fix rofi rsync pavucontrol farge-git \
            ranger python-pip noto-fonts-emoji noto-fonts-cjk xwallpaper xcolor imlib2 fzf     \
            exa bat file-roller geany geany-plugins gvfs gvfs-mtp htop wal-git imlib2 xclip    \
            xorg-xsetroot simplescreenrecorder ytfzfim cava ps_mem unimatrix xdg-user-dirs     \
            ueberzug pacman-contrib catppuccin-gtk-theme xdotool xclip scrot noto-fonts

        elif [[ -e /usr/bin/yay ]]; then
            echo -e "$prefix yay detected. Installing dependencies..."
            yay -S python ffmpeg pipewire pipewire-alsa pipewire-pulse alsa-utils dunst scrot  \
            thunar thunar-archive-plugin thunar-volman ffmpegthumbnailer tumbler w3m neovim    \
            viewnior mpv htop lxappearance picom-jonaburg-fix rofi rsync pavucontrol farge-git \
            ranger python-pip noto-fonts-emoji noto-fonts-cjk xwallpaper xcolor imlib2 fzf     \
            exa bat file-roller geany geany-plugins gvfs gvfs-mtp htop wal-git imlib2 xclip    \
            xorg-xsetroot simplescreenrecorder ytfzfim cava ps_mem unimatrix xdg-user-dirs     \
            ueberzug pacman-contrib catppuccin-gtk-theme xdotool noto-fonts
        else
            # Line from https://github.com/Axarva/dotfiles-2.0/blob/9f0a71d7b23e1213383885f2ec641da48eb01681/install-on-arch.sh#L67
            read -r -p "Would you like to install paru? [Y/n]: " paru
            sleep 1.0

            case $paru in
                [yY][*])
                    git clone https://aur.archlinux.org/paru.git $HOME/.setup-scripto
                    (cd $HOME/.setup-scripto && makepkg -si)

                    echo -e "$prefix paru installed. Installing dependencies..."
                    paru -S python ffmpeg pipewire pipewire-alsa pipewire-pulse alsa-utils dunst       \
                    thunar thunar-archive-plugin thunar-volman ffmpegthumbnailer tumbler w3m neovim    \
                    viewnior mpv htop lxappearance picom-jonaburg-fix rofi rsync pavucontrol farge-git \
                    ranger python-pip noto-fonts-emoji noto-fonts-cjk xwallpaper xcolor imlib2 fzf     \
                    exa bat file-roller geany geany-plugins gvfs gvfs-mtp htop wal-git imlib2 xclip    \
                    xorg-xsetroot simplescreenrecorder ytfzfim cava ps_mem unimatrix xdg-user-dirs     \
                    ueberzug pacman-contrib catppuccin-gtk-theme xdotool xclip scrot noto-fonts
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
    
    if [[ -d $HOME/.oh-my-zsh/ ]]; then
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
    
    if [[ -d $HOME/.oh-my-zsh/ ]]; then
        git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        git clone --depth 1 https://github.com/zsh-users/zsh-completions.git ${ZSH_CUSTOM:~/.oh-my-zsh/custom}/plugins/zsh-completions
    fi
    
    echo -e "$prefix Oh-My-Zsh plugins installed!"
    sleep 0.7
}

installNerdFonts() {
    clear
    
    sleep 1
    echo -e "$prefix Downloading Nerd Fonts..."
    echo -e "$prefix If this don't work, delete this posix!"
    
    if [[ -d $HOME/Donwloads/ ]]; then
        mkdir -p $HOME/Downloads/nerdfonts/
        wget https://github.com/ryanoasis/nerd-fonts/releases/download/2.2.0-RC/CascadiaCode.zip
        wget https://github.com/ryanoasis/nerd-fonts/releases/download/2.2.0-RC/Iosevka.zip
        wget https://github.com/ryanoasis/nerd-fonts/releases/download/2.2.0-RC/JetBrainsMono.zip
        wget https://github.com/ryanoasis/nerd-fonts/releases/download/2.2.0-RC/Noto.zip
        unzip *.zip $HOME/Downloads/nerdfonts/
    fi
    
    echo -e "$prefix nerdfonts downloaded!"
    sleep 0.7
}

copyFonts() {
    clear
    
    sleep 1
    echo -e "$prefix Copying fonts..."
    echo -e "$prefix If this don't work, delete this posix."
    
    if [[ -d $HOME/Downloads/nerdfonts/ ]]; then
        sudo cp -R $HOME/Downloads/nerdfonts/ /usr/share/fonts/
    fi
    
    echo -e "$prefix nerd fonts installed!"
    sleep 0.7
}

copyFiles() {
    clear
    
    sleep 1
    echo -e "$prefix Syncing files..."
    echo -e "$prefix Will make a sync if dwm, config and scripts doesn't exists."

    if [[ -d $HOME/ ]]; then
        rsync -avxHAXP --exclude '.git*' .* ~/
    fi

    echo -e "$prefix Synced all configs files!"
    sleep 0.7



    if [[ -d $HOME/lnxdwm/ ]]; then
        mkdir $HOME/lnxdwm_backup/ && mv $HOME/lnxdwm/* $HOME/lnxdwm_backup/
        cp -r ./lnxdwm/* $HOME/lnxdwm/
    else
        mkdir $HOME/lnxdwm && cp -r ./lnxdwm/* $HOME/lnxdwm/
    fi

    echo -e "$prefix Copied DWM configuration!"
    sleep 0.7

    if [[ -d $HOME/lnxdwm/ ]]; then
        sudo make install
    else
        mkdir $HOME/lnxdwm && cp -r ./lnxdwm/* $HOME/lnxdwm/ && sudo make install
    fi

    echo -e "$prefix Make DWM magic!"
    sleep 0.7

    if [[ -d $HOME/st/ ]]; then
        mkdir $HOME/st_backup && mv $HOME/st/* $HOME/st_backup/
        cp -r ./st/* $HOME/st/
    else
        mkdir $HOME/st/ && cp -r ./st/* $HOME/st/
    fi

    echo -e "$prefix Copied st configuration!"
    sleep 0.7

    if [[ -d $HOME/st/ ]]; then
        mkdir $HOME/st_backup && mv $HOME/st/* $HOME/st_backup/
        cp -r ./st/* $HOME/st/
    else
        mkdir $HOME/st/ && cp -r ./st/* $HOME/st/ && sudo make install
    fi

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
    rm -rf $HOME/.setup-scripto

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
