#!/bin/bash
source /etc/profile

# use grub2
cat <<DATAEOF >> "$chroot/etc/portage/package.accept_keywords/grub"
sys-boot/grub:2
DATAEOF

# install grub
chroot "$chroot" emerge grub

# tweak timeout
chroot "$chroot" sed -i "s/#GRUB_TIMEOUT=/GRUB_TIMEOUT=/g" /etc/default/grub
chroot "$chroot" sed -i "s/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/g" /etc/default/grub
# Force old interface naming convention.
chroot "$chroot" sed -i "s/#GRUB_CMDLINE_LINUX=/GRUB_CMDLINE_LINUX=/g" /etc/default/grub
chroot "$chroot" sed -i "s/GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX=\"net.ifnames=0\"/g" /etc/default/grub

# make the disk bootable
chroot "$chroot" /bin/bash <<DATAEOF
source /etc/profile && \
env-update && \
mkdir -p /boot/grub && \
grub-mkconfig -o /boot/grub/grub.cfg && \
grub-install --no-floppy /dev/sda
DATAEOF
