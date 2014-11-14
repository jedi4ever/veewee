#!/bin/bash

# Requires
#   reboot.sh

pacman -S --noconfirm sudo

# Sudo setup
cat <<EOF > /etc/sudoers
root ALL=(ALL) ALL
%wheel ALL=(ALL) NOPASSWD: ALL
EOF
