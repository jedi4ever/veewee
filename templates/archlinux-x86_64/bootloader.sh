#!/bin/bash

# Requires
#   pacman.sh

# Chroot into the new system and install the bootloader
arch-chroot /mnt <<ENDCHROOT
pacman -S --noconfirm grub-bios
grub-install --recheck --debug /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
ENDCHROOT
