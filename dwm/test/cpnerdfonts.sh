#!/bin/bash

sleep 1
    echo -e "$prefix Copying fonts..."
    echo -e "$prefix If this don't work, delete this posix."
    
    if [[ -d $HOME/Downloads/nerdfonts/ ]]; then
        sudo cp -R $HOME/Downloads/nerdfonts/ /usr/share/fonts/
    fi
    
    echo -e "$prefix nerd fonts installed!"
    sleep 0.7
