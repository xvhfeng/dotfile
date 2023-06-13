#!/bin/bash

currpath=`pwd`

if [ -f ~/.bash_profile ]; then
    mv ~/.bash_profile ~/.bash_profile.mybkp
fi
ln -s $currpath"/bash_profile" ~/.bash_profile

if [ -f ~/.bashrc ]; then
    mv ~/.bashrc ~/.bashrc.mybkp
fi
ln -s $currpath"/bashrc" ~/.bashrc


if [ -f ~/.aliasrc ]; then
    mv ~/.aliasrc ~/.aliasrc.mybkp
fi
ln -s $currpath"/aliasrc" ~/.aliasrc


if [ -f ~/.git-completion.bash ]; then
    mv ~/.git-completion.bash ~/.git-completion.bash.mybkp
fi
ln -s $currpath"/git-completion.bash" ~/.git-completion.bash

if [ -f ~/.inputrc ]; then
    mv ~/.inputrc ~/.inputrc.mybkp
fi
ln -s $currpath"/inputrc" ~/.inputrc

# 根据当前目录得到上级目录  
fpath=$(dirname $currpath)  

chmod -R +x "$fpath/"


source ~/.bashrc

echo "Init System Over!!!"
echo "Notice:File in the path:"$fpath" is setted 777"



ln -s `pwd`/aliasrc ~/.aliasrc
ln -s `pwd`/bash_profile ~/.bash_profile
ln -s  `pwd`/bashrc  ~/.bashrc
ln -s `pwd`/dircolors ~/.dircolors
ln -s `pwd`/git-completion.bash ~/.git-completion.bash
ln -s `pwd`/path.bash ~/.path.bash

