#!/usr/bin/env sh

######################################################################
# @author      : xuhaifeng (xuhaifeng@P_HAIFENGXU-MB2)
# @file        : install-commit-msg-hook
# @created     : Sunday Nov 20, 2022 21:59:37 CST
#
# @description : install version contorl showing in git commit log
# @howto:
#               1. copy version.h and upd-version.sh to project root path
#               2. copy this file and compose-commit-msg.sh tp peoject root path
#               3. set git user and git user.mail
#               4. run this script
######################################################################


git config core.editor nvim
git config --global commit.template $MYGIT_HOME/mygit-commit-msg-template
echo '. "$(dirname "$1")"/../compose-commit-msg.sh' >> .git/hooks/commit-msg 
chmod 777 ./compose-commit-msg.sh
chmod 777 .git/hooks/commit-msg


