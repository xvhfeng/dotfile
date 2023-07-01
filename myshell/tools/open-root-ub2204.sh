#!/bin/bash

#set root password
# sudo passwd root
 
#notes Document content
sudo sed -i "s/.*root quiet_success$/#&/" /etc/pam.d/gdm-autologin
sudo sed -i "s/.*root quiet_success$/#&/" /etc/pam.d/gdm-password
 
#modify profile
sudo sed -i 's/^mesg.*/tty -s \&\& mesg n \|\| true/' /root/.profile
 
#install openssh
sudo apt install openssh-server
 
#delay
sleep 1
 
#modify conf
sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
 
#restart server
sudo systemctl restart ssh
