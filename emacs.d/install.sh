#!/usr/bin/env sh

######################################################################
# @author      : bgm (bgm@dazuideMacBook-Pro.local)
# @file        : install
# @created     : Friday Feb 23, 2024 22:41:01 CST
#
# @description :
######################################################################

if not [ -f ~/.config ]; then
    mkdir ~/.config
fi

ln -s $(pwd) ~/.config/emacs
