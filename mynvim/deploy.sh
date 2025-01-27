#!/usr/bin/env sh

######################################################################
# @author      : bgm (bgm@dazuideMacBook-Pro.local)
# @file        : deploy
# @created     : Sunday Jan 26, 2025 17:14:22 CST
#
# @description : 
######################################################################


cd ./reps/telescope-fzf-native.nvim && make

# 全局安装pynvim ，if已经安装了pyevn，
pip3 install 'pynvim @ git+https://github.com/neovim/pynvim' --break-system-packages


