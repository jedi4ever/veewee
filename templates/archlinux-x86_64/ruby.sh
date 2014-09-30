#!/bin/bash

# Requires
#   reboot.sh

pacman -S --noconfirm ruby

# Don't install RDoc and RI to save time and space
cat <<EOF >> /etc/gemrc
gem: --no-document
EOF
