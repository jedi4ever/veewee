#!/bin/bash
source /etc/profile

# Set up for better USB support

# install usbutils (which includes 'lsusb') and libusb
chroot "$chroot" emerge sys-apps/usbutils

# add exFAT filesystem support.
# (exFAT requires a kernel with a FUSE module)
#chroot "$chroot" emerge sys-fs/fuse sys-fs/exfat-utils sys-fs/fuse-exfat
