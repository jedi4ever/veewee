#!/bin/bash
source /etc/profile

# use grub2
cat <<DATAEOF >> "$chroot/etc/portage/package.keywords"
sys-boot/grub:2
DATAEOF

# install grub
chroot "$chroot" emerge grub

# tweak timeout
chroot "$chroot" sed -i "s/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/g" /etc/default/grub

# make the disk bootable
chroot "$chroot" /bin/bash <<DATAEOF
source /etc/profile && \
env-update && \
grep -v rootfs /proc/mounts > /etc/mtab && \
mkdir /boot/grub2 && \
grub2-mkconfig -o /boot/grub2/grub.cfg && \
grub2-install --no-floppy /dev/sda
DATAEOF
