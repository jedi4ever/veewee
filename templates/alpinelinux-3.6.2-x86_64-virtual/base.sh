#!/bin/ash

# Requires
#   settings.sh

source /etc/profile

# grsec will get in the way, disable it for the installation
for i in $(sysctl -a | grep grsec | awk -F '=' '{print $1}'); do 
	sysctl -w ${i}=0 
done

apk add e2fsprogs syslinux

fdisk /dev/sda << EOF
n
p
1

+100M
a
1
n
p
2


t
2
8e
w
EOF

BOOT_DEV=/dev/sda1
ROOT_DEV=/dev/sda2

mkfs.ext4 $ROOT_DEV
mkfs.ext4 $BOOT_DEV
mount -t ext4 $ROOT_DEV /mnt
mkdir /mnt/boot
mount -t ext4 $BOOT_DEV /mnt/boot

setup-disk -m sys /mnt
dd bs=$(stat -c %s /mnt/usr/share/syslinux/mbr.bin) \
   count=1 conv=notrunc \
   if=/mnt/usr/share/syslinux/mbr.bin \
   of=/dev/sda

extlinux --install /mnt/boot

# Prepare Chroot
mount -t proc none "$chroot/proc"
mount -t sysfs sys "$chroot/sys"
mount --rbind /dev "$chroot/dev"
cp /etc/resolv.conf "$chroot/etc/"
date -u > "$chroot/etc/vagrant_box_build_time"

chroot $chroot /bin/ash <<DATAEOF
update-extlinux --warn-only

cat <<EOF> /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
	hostname alpine
EOF

rc-update add networking boot
rc-update add sshd default
sed -i 's/PermitRootLogin/# PermitRootLogin/g' /etc/ssh/sshd_config
setup-hostname alpine

DATAEOF


