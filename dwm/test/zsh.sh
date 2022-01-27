#!/bin/bash

sleep 1
    echo -e "$prefix Install Oh-My-Zsh..."
    echo -e "$prefix If this don't work, delete this posix."
    
    if [[ -d $HOME/.oh-my-zsh/ ]]; then
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
    
    echo -e "$prefix Oh-My-Zsh installed!"
    sleep 0.7
