#!/bin/bash

# Requires
#   virtualbox.sh
#   sudo.sh
#   puppet.sh

date > /etc/vagrant_box_build_time

# Add the vagrant user
useradd -m -G wheel,vboxsf -r vagrant
passwd -d vagrant
passwd vagrant<<EOF
vagrant
vagrant
EOF

# Install the "insecure" public key
mkdir -m 700 /home/vagrant/.ssh

curl -L 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' \
  -o /home/vagrant/.ssh/authorized_keys

chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh
