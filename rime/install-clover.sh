#!/usr/bin/env sh

######################################################################
# @author      : xvhfeng (xvhfeng@xvhfengdeMacBook-Air.local)
# @file        : install-clover
# @created     : Sunday Sep 20, 2026 18:11:28 CST
#
# @description :
######################################################################

[ -r $HOME/Library/Rime ] && rm -rf $HOME/Library/Rime

ln -s $(pwd)/clover $HOME/Library/Rime



