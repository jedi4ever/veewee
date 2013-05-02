#!/bin/bash

# Requires
#   reboot.sh

pacman -S --noconfirm ruby

# Don't install RDoc and RI to save time and space
cat <<EOF >> /etc/gemrc
install: --no-rdoc --no-ri
update:  --no-rdoc --no-ri
EOF
