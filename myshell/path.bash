#!/bin/bash

SYSTEM=$(uname -s)
if [ $SYSTEM == "Darwin" ]; then
    NVIM_HOME=/Users/xuhaifeng/pkgs/nvim/nvim-osx64/
    export NVIM_HOME
    export PATH=$NVIM_HOME/bin:$PATH
    JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_301.jdk/Contents/Home
    PATH=$JAVA_HOME/bin:$PATH
    export JAVA_HOME
    export PATH

    VIM_HOME=/usr/local/vim8
    PATH=$VIM_HOME/bin:$PATH
    export VIM_HOME
    export PATH

    export PATH=/usr/local/opt/ruby/bin:$PATH
    export MYGIT_HOME=/Users/xuhaifeng/pkgs/mygit
    export PATH=$MYGIT_HOME:$PATH
    export GO_HOME=/Users/xuhaifeng/works/bin/go
    export PATH="$GO_HOME/bin/:$PATH"
    export MVN_HOME=/Users/xuhaifeng/works/bin/maven
    export PATH="$MVN_HOME/bin/:$PATH"
    export PROTOC_HOME=/Users/xuhaifeng/works/bin/protoc3
    export PATH="$PROTOC_HOME/bin/:$PATH"
    export PATH=/Users/xuhaifeng/works/bin/trpc:$PATH
    export PROTS_INSTALL_HOME=/opt/local
    export PATH=$PROTS_INSTALL_HOME/bin:$PATH
    export MYMAC_HOME=/Users/xuhaifeng/pkgs/mymac
    export PATH=$MYMAC_HOME/bin:$PATH
    export VAGRANT_HOME=/Users/xuhaifeng/works/vms/.vagrant.d
    export CARGO_HOME=/Users/xuhaifeng/.cargo
    export PATH=$CARGO_HOME/bin:$PATH
    export PATH=/Users/xuhaifeng/.local/bin:$PATH
    export PATH=/opt/local/libexec/gnubin/:$PATH
    export PATH=/Users/xuhaifeng/Library/Python/3.9/bin:$PATH
fi
if [ $SYSTEM == "Linux" ]; then
    export DOTFILE_PATH=/opt/dotfile
    export NVIM_HOME=$DOTFILE_PATH/bin/nvim-linux64
    export PATH=$NVIM_HOME/bin:$PATH
    export MYGIT_HOME=$DOTFILE_PATH/mygit
    export PATH=$MYGIT_HOME:$PATH
    export GO_HOME=$DOTFILE_PATH/bin/go1.20.5
    export PATH=$GO_HOME/bin/:$PATH
    export RUST_HOME=$DOTFILEPATH/rust-1.70.0
    export CARGO_HOME=$RUST_HOME/cargo
    export RUSTC_HOME=$RUST_HOME/rustc
    export PATH=$CARGO_HOME/bin:$RUSTC_HOME/bin:$PATH
    export PATH=$DOTFILE_PATH/myshell/tools:$PATH
fi
