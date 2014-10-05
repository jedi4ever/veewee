PARALLELS_TOOLS_ISO=prl-tools-lin.iso
mount -o loop $PARALLELS_TOOLS_ISO /media/cdrom
/media/cdrom/install --install-unattended-with-deps --progress
umount /media/cdrom