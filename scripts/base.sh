#!/bin/bash -eux

# Set variables.
export HISTSIZE=0
locale-gen en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Upgrade.
apt-get update
apt-get -y upgrade

# Basic stuff.
apt-get install -y vim git zip unzip curl wget screen htop

# Tweak sshd to prevent DNS resolution (speed up logins)
echo 'UseDNS no' >> /etc/ssh/sshd_config

# Fix for Ubuntu/Virtualbox shit.
# Starting from 14.04.3 in virtualbox we got a black screen each reboot.
# This is used to re-init the video.
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet”/GRUB_CMDLINE_LINUX_DEFAULT=“text”/g' /etc/default/grub
update-grub