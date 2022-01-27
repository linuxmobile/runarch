#!/bin/bash

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
