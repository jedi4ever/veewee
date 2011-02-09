#!/bin/bash

#https://wiki.archlinux.org/index.php/Install_from_Existing_Linux

ARCH=i686
mkdir /tmp/archlinux
cd /tmp/archlinux

alias wget='wget --trust-server-names'

wget http://www.archlinux.org/packages/core/$ARCH/pacman/download/
wget http://www.archlinux.org/packages/core/any/pacman-mirrorlist/download/

wget http://www.archlinux.org/packages/core/$ARCH/libfetch/download/
wget http://www.archlinux.org/packages/core/$ARCH/libarchive/download/
wget http://www.archlinux.org/packages/core/$ARCH/bzip2/download/
wget http://www.archlinux.org/packages/core/$ARCH/openssl/download/
wget http://www.archlinux.org/packages/core/$ARCH/xz/download/
wget http://www.archlinux.org/packages/core/$ARCH/expat/download/

for f in *.tar.xz ; do unxz -v $f ; done
for f in *.tar ; do tar xvf $f ; done
for f in *.tar.gz ; do tar xzvf $f ; done


export PATH=/tmp/archlinux/usr/bin:$PATH
export LD_LIBRARY_PATH=/tmp/archlinux/usr/lib:/tmp/archlinux/lib:$LD_LIBRARY_PATH
alias pacman="pacman --config /tmp/archlinux/etc/pacman.conf"

cd /
for f in /tmp/archlinux/pacman-*pkg.tar.gz ; do
  tar xzf $f
done

#/etc/pacman.d/mirrorlist
#enable a mirror

#Partition the disk
sfdisk --force /dev/sda <<EOF
# partition table of /dev/sda
unit: sectors

/dev/sda1 : start=     2048, size= 18874368, Id=83
/dev/sda2 : start= 18876416, size=  2095104, Id=82
/dev/sda3 : start=        0, size=        0, Id= 0
/dev/sda4 : start=        0, size=        0, Id= 0
EOF

sleep 2

#Format the first disk
mkfs.ext3 /dev/sda1

#Format the swap and use it
mkswap /dev/sda2
swapon /dev/sda2

mkdir /newarch 
mount /dev/sda1 /newarch

mkdir -p /newarch/var/lib/pacman 

#setting pacman - mirror - Belgium
sed -i 's/^#\(.*kangaroot.*\)/\1/' /etc/pacman.d/mirrorlist

pacman -Sy -r /newarch

#pacman: error while loading shared libraries: libbz2.so.1.0: cannot open shared object file: No such file or directory
#require bzip2 
pacman --noconfirm --cachedir /newarch/var/cache/pacman/pkg -S base -r /newarch 

#Create the devices
cd /newarch/dev 
rm -f console ; mknod -m 600 console c 5 1 
rm -f null ; mknod -m 666 null c 1 3 
rm -f zero ; mknod -m 666 zero c 1 5

#Copy the dns information (cp is aliased so we use the binary)
/bin/cp -f /etc/resolv.conf /newarch/etc/ 

#Mount the process architecture
mount -t proc proc /newarch/proc
mount -t sysfs sys /newarch/sys
mount -o bind /dev /newarch/dev

chroot /newarch pacman --noconfirm -S kernel26 
#chroot /newarch pacman --noconfir -S packagename

#set the mirror list within the machine
chroot /newarch sed -i 's/^#\(.*kangaroot.*\)/\1/' /etc/pacman.d/mirrorlist
#/etc/fstab
#We need a partition!

echo "echo '/dev/sda1              /         ext4      defaults,noatime        0	0' >> /etc/fstab"|chroot /newarch sh -
echo "echo '/dev/sda2              swap          swap      defaults                0      0'>> /etc/fstab"|chroot /newarch sh -

#/etc/rc.conf

#hostname
chroot /newarch sed -i 's/^HOSTNAME=\(.*\)/HOSTNAME=vagrant-arch/' /etc/rc.conf
#gateway

#/etc/hosts
#/etc/mkinitcpio.conf
#/etc/local.gen


#grub
chroot /newarch grep -v rootfs /proc/mounts > /etc/mtab  
chroot /newarch grub-install /dev/sda
chroot /newarch cp -a /usr/lib/grub/i386-pc/* /boot/grub

#create vagrant user 

#chef
cd /
umount /newarch/{proc,sys,dev}
umount /newarch

reboot