#!/usr/bin/env sh

######################################################################
# @author      : xvhfeng (xvhfeng@xvhfeng-thinkpad-t490)
# @file        : locker
# @created     : Tuesday Jun 13, 2023 08:40:10 CST
#
# @description : 
######################################################################

exec xautolock -detectsleep -time 3 -locker "i3lock -d -c 000070" -notify 30 -notifier "notify-send -u critical -t 10000 -- 'LOCKING screen in 30 seconds'"
