#!/bin/bash

echo -e "$prefix paru detected. Installing dependencies..."
            paru -S python ffmpeg pipewire pipewire-alsa pipewire-pulse alsa-utils dunst       \
            thunar thunar-archive-plugin thunar-volman ffmpegthumbnailer tumbler w3m neovim    \
            viewnior mpv htop lxappearance picom-jonaburg-fix rofi rsync pavucontrol farge-git \
            ranger python-pip noto-fonts-emoji noto-fonts-cjk xwallpaper xcolor imlib2 fzf     \
            exa bat file-roller geany geany-plugins gvfs gvfs-mtp htop wal-git imlib2 xclip    \
            xorg-xsetroot simplescreenrecorder ytfzfim cava ps_mem unimatrix xdg-user-dirs     \
            ueberzug pacman-contrib catppuccin-gtk-theme xdotool xclip scrot noto-fonts
