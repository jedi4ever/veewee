#!/bin/bash

# Requires
#   basedevel.sh
#   user.sh

pacman -S --noconfirm --needed base-devel

cd /tmp
curl 'https://aur.archlinux.org/packages/pa/packer/packer.tar.gz' -o packer.tar.gz
tar xzf packer.tar.gz

# makepkg should not be run as root
chown -R veewee:veewee packer
cd packer
su veewee -c 'makepkg -si --noconfirm'

# Clean up
cd ..
rm -rf packer*

# Now Arch User Repository packages can be installed using packer.
