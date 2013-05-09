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
# Get reflector so that we can update the mirrorlist
pacstrap /mnt base reflector
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into the new system
arch-chroot /mnt <<ENDCHROOT
# Previously dhcpcd.service was enabled. However, in my testing it repeatedly
# failed to connect to the network on reboot. Enable dhcpcd@.service has worked
# in my case. My guess is that this is due to the line
# After=sys-subsystem-net-devices-%i.device
# in the service file.
# Restarting dhcpcd.service after boot or using Network Manager instead of
# dhcpcd also works
# Maybe a related bug report?
# https://bugs.freedesktop.org/show_bug.cgi?id=59964
# Replace this with a better fix, when available.

systemctl enable dhcpcd\@eth0.service

# Disable systemd's Predictable Network Interface Names
ln -s /dev/null /etc/udev/rules.d/80-net-name-slot.rules

# Set root password
passwd<<EOF
veewee
veewee
EOF
ENDCHROOT
