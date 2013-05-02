#!/bin/bash

# Requires
#   base.sh

# Chroot into the new system and set up Pacman and the mirrorlist
arch-chroot /mnt <<ENDCHROOT
# Update the mirrorlist to 5 recently updated mirrors sorted by download rate
reflector --verbose -l 5 --sort rate --save /etc/pacman.d/mirrorlist

# Upgrade Pacman DB
pacman-db-upgrade

# Force pacman to refresh the package lists
pacman -Syy

# Remove reflector as not required anymore
pacman -Rns --noconfirm reflector
ENDCHROOT
