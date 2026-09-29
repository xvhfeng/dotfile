#!/bin/bash

[ -d ~/.emacs.d ] && rm -rf ~/.emacs.d
ln -s $(pwd) ~/.emacs.d