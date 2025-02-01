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


brew install tree-sitter
sudo npm install tree-sitter-cli -g
brew install lolcat

# 设置mason安装的可执行文件到path
echo "export PATH=$HOME/.local/share/nvim/mason/bin:$PATH" >> ~/.bashrc

#install sqls
# 手工github下载，然后放置到PATH目录即可
# go install 先设置好go的国内代理
# go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/,direct
# 然后再使用mason安装即可

#注意：
# mason和mason lspconfig安装的提供了格式化和lint功能
# tree-sitter貌似没啥用
# 目前，py sql c 都ok

