#!/bin/bash

# Requires
#   base.sh

if [ -f .veewee_params ]; then
  . .veewee_params
fi

# PACMAN_REFLECTOR_ARGS can be used to pick a suitable mirror for pacman
if [ -z "$PACMAN_REFLECTOR_ARGS" ]; then
  export PACMAN_REFLECTOR_ARGS='--verbose -l 5 --sort rate --save /etc/pacman.d/mirrorlist'
fi

# Chroot into the new system and set up Pacman and the mirrorlist
arch-chroot /mnt <<ENDCHROOT
# Update the mirrorlist to 5 recently updated mirrors sorted by download rate
reflector $PACMAN_REFLECTOR_ARGS

# Upgrade Pacman DB
pacman-db-upgrade

# Force pacman to refresh the package lists
pacman -Syy

# Remove reflector as not required anymore
pacman -Rns --noconfirm reflector
ENDCHROOT
