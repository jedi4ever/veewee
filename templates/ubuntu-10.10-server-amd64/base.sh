#!/bin/bash

if [ -f .veewee_params ]
then
  . .veewee_params
fi

# Replace all ubuntu mirror with the old-release mirror
sed -i -e 's@http://.*.ubuntu.com@http://old-releases.ubuntu.com@' /etc/apt/sources.list

# etc., and remove optional things to trim down the machine.
apt-get -y update
apt-get -y upgrade
apt-get -y install linux-headers-$(uname -r) build-essential
apt-get -y install zlib1g-dev libssl-dev libreadline5-dev
apt-get install acpid

# Setup sudo to allow no-password sudo for "admin"
cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers
