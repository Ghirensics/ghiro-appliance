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
apt-get install -y vim git zip unzip curl wget