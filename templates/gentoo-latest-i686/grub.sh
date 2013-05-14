#!/bin/bash
source /etc/profile

# install grub
chroot "$chroot" emerge grub

# add installed kernel entry
cat <<DATAEOF > "$chroot/boot/grub/grub.conf"
default 0
timeout 1

title=Gentoo Linux ($kernel_version-gentoo)
root (hd0,0)
kernel /boot/kernel-genkernel-x86-$kernel_version-gentoo root=/dev/ram0 real_root=/dev/sda4
initrd /boot/initramfs-genkernel-x86-$kernel_version-gentoo
DATAEOF

# make the disk bootable
chroot "$chroot" /bin/bash <<DATAEOF
source /etc/profile && \
env-update && \
grep -v rootfs /proc/mounts > /etc/mtab && \
grub-install --no-floppy /dev/sda
DATAEOF