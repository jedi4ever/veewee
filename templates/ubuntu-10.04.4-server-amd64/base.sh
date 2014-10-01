#!/bin/bash

if [ -f .veewee_params ]
then
  . .veewee_params
fi

# Apt-install various things necessary for Ruby, guest additions,
# etc., and remove optional things to trim down the machine.
apt-get -y update
apt-get -y upgrade
apt-get -y install linux-headers-$(uname -r) build-essential
apt-get -y install zlib1g-dev libssl-dev libreadline5-dev
apt-get clean

# Setup sudo to allow no-password sudo for "admin"
cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers

# Install NFS client
apt-get -y install nfs-common

# Need conditionals around `mesg n` so that Chef doesn't throw
# `stdin: not a tty`
sed -i '$d' /root/.profile
cat << 'EOH' >> /root/.profile
if `tty -s`; then
  mesg n
fi
EOH
