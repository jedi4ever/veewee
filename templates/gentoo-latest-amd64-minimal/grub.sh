#!/bin/bash
source /etc/profile

# use grub2
cat <<DATAEOF >> "$chroot/etc/portage/package.accept_keywords/grub"
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
mkdir -p /boot/grub2 && \
ln -sf /boot/grub2 /boot/grub && \
grub2-mkconfig -o /boot/grub/grub.cfg && \
grub2-install --no-floppy /dev/sda
DATAEOF
