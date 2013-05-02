#!/bin/bash

# Partition disk
fdisk /dev/sda << EOF
n
p
1


w
y
EOF

# Format the partition
mkfs.ext4 /dev/sda1

# Install the base system
mount /dev/sda1 /mnt
pacstrap /mnt base
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into the new system
arch-chroot /mnt <<ENDCHROOT
# Set up mirrors for the new system's Pacman
sed -i 's/^#\(.*leaseweb.*\)/\1/' /etc/pacman.d/mirrorlist

# Upgrade Pacman DB
pacman-db-upgrade
pacman -Syy

# Make sure to have dhcpcd at startup
systemctl enable dhcpcd.service

# Set root password
passwd<<EOF
veewee
veewee
EOF
ENDCHROOT
