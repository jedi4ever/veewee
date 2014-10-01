#!/bin/bash

if [ -f .veewee_params ]
then
  . .veewee_params
fi

# Installing the virtualbox guest additions
if test -f /home/veewee/.vbox_version
then
# postinstall.sh created from Mitchell's official lucid32/64 baseboxes
date > /etc/vagrant_box_build_time

# Create the user vagrant with password vagrant

useradd -G admin -p $(perl -e'print crypt("vagrant", "vagrant")') -m -s /bin/bash -N vagrant

# Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

# Install NFS client
apt-get -y install nfs-common

# Zero out the free space to save space in the final image:
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

fi

