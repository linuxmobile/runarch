#!/bin/bash

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
