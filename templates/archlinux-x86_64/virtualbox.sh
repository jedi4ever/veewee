#!/bin/bash

# Requires
#   reboot.sh
#   user.sh

# Adapted from https://wiki.archlinux.org/index.php/VirtualBox

# Install and set up VirtualBox Guest Additions
pacman -S --noconfirm virtualbox-guest-utils-nox

cat <<EOF > /etc/modules-load.d/virtualbox.conf
vboxguest
vboxsf
vboxvideo
EOF

# For shared folders to work
groupadd vboxsf
gpasswd -a veewee vboxsf

# To synchronise guest date with host and for auto-mounting of shared folders
systemctl enable vboxservice.service
