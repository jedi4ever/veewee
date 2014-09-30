#! /bin/sh -xv

# Swiped from  funtoo-latest-generic_64-stable/postinstall.sh

#Partition the disk
# Gentoo live CD were using doesn't have gdisk and it looks 
# to be interactive like fdisk.  sfdisk is scritable but has issues.
#
# If you adjust, best to read this 
#     http://www.spinics.net/lists/util-linux-ng/msg03406.html
#
# Basically, all partitioning programs are wonky, sfdisk is scriptable, but likes
# to keeps things too tight skipping post-MBR spacing and "grub-install" fails later.
# Take the advice of the email and partition your drive with fdisk and dump it with 
#
#    sfdisk -uS -d /dev/sda 
#
# and plug those values into the script.  The --force by sector will get
# you what fdisk layed out and gets something grub-install can deal with.   fun...
#
#
#/boot -> /dev/sda1   200M, left 2Meg of space for grub-install 
#swap  -> /dev/sda2   1.5G
#root  -> /dev/sda3   Rest of space and bootable

echo "Running: $0 from `pwd`"
echo

sfdisk --force -uS /dev/sda <<EOF
4096,409600,L
413696,3072000,S
3485696,17281024,L,*
EOF

if [ "$?" -ne "0" ]; then
  echo "sfdisk failed"
  exit $?
fi

sleep 2

#Format the /boot
mke2fs -t ext2 /dev/sda1

#Main partition /
mke2fs -t ext4 /dev/sda3

#Format the swap and use it
mkswap /dev/sda2
swapon /dev/sda2

# Mount
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

mkdir /mnt/rootfs
mount /dev/sda3 /mnt/rootfs


cd /mnt/rootfs

ls -la /mnt/
