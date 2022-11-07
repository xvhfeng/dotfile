#!/bin/bash
install_config() {
    
    if [ ! -e "$HOME/.config/nvim" ];then
          mkdir -p "$HOME/.config/nvim"
    fi 
    ln -s -f $PWD/init.lua $HOME/.config/nvim/init.lua
    ln -s -f $PWD/coc-settings.json $HOME/.config/nvim/coc-settings.json
    echo $System
}
install_depend(){
    #pip install flake8
    #pip install pynvim
    # install fzf
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
    #if [[ "$(uname)" == "Darwin" ]];then
    #    brew install neovim
    #    brew install ag
    #    brew install rg
    #elif [[ -n "$(uname -a | grep Linux )" ]]; then
    #    sudo apt-get install neovim
    #    sudo apt-get install ag
    #    sudo apt-get install rg
    #else
    #    printf "\033[31m ERROR: Don't support install depend for your system(only configure for WSL & MacOS), please install manually.\033[0m\n"
    #fi
}
install_depend
install_config
