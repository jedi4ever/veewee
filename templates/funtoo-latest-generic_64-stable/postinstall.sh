#!/bin/bash

date > /etc/vagrant_box_build_time

#Based on http://www.funtoo.org/wiki/Funtoo_Linux_Installation

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

sfdisk --force -uS /dev/sda <<EOF
4096,409600,L
413696,3072000,S
3485696,17281024,L,*
EOF

sleep 2

#Format the /boot
mke2fs -t ext2 /dev/sda1

#Main partition /
mke2fs -t ext4 /dev/sda3

#Format the swap and use it
mkswap /dev/sda2
swapon /dev/sda2

#Mount the new disk
mkdir /mnt/funtoo
mount /dev/sda3 /mnt/funtoo
mkdir /mnt/funtoo/boot
mount /dev/sda1 /mnt/funtoo/boot
cd /mnt/funtoo

#Note: we retry as sometimes mirrors fail to have the files
#Download a stage3 archive
wget --tries=5 http://ftp.osuosl.org/pub/funtoo/funtoo-stable/x86-64bit/generic_64/stage3-current.tar.xz
tar xpf stage3*

#Chroot
mount --bind /proc ./proc
mount --bind /dev ./dev
cp /etc/resolv.conf /mnt/funtoo/etc/
chroot /mnt/funtoo env-update

# git installed from stage3 tarball
chroot /mnt/funtoo emerge --sync

# California dreamin
cd /mnt/funtoo/etc
rm -f localtime
ln -s ../usr/share/zoneinfo/America/Los_Angeles localtime
cd /mnt/funtoo

# get fstab defined
cat <<FSTABEOF > /mnt/funtoo/etc/fstab
# The root filesystem should have a pass number of either 0 or 1.
# All other filesystems should have a pass number of 0 or greater than 1.
#
# See the manpage fstab(5) for more information.
#
# <fs>                  <mountpoint>    <type>          <opts>                   <dump/pass>

/dev/sda1               /boot           ext2            noauto,noatime           1 2
/dev/sda2               none            swap            sw                       0 0
/dev/sda3               /               ext4            noatime                  0 1
#/dev/cdrom             /mnt/cdrom      auto            noauto,ro                0 0
none                    /dev/shm        tmpfs           nodev,nosuid,noexec      0 0
FSTABEOF

# dhcp
chroot /mnt/funtoo rc-update add dhcpcd default

# Get the kernel sources
echo 'MAKEOPTS="-j9"' >> /mnt/funtoo/etc/make.conf
#echo 'MAKEOPTS="-j9"' >> /mnt/funtoo/etc/genkernel.conf
echo "sys-kernel/sysrescue-std-sources binary" >> /mnt/funtoo/etc/portage/package.use
echo "app-emulation/virtualbox-guest-additions" >> /mnt/funtoo/etc/portage/package.keywords
echo 'MAKEOPTS="-j9" emerge sysrescue-std-sources' | chroot /mnt/funtoo /bin/bash -

# Make the disk bootable
chroot /mnt/funtoo emerge boot-update

cat <<GRUBCONF > ./etc/boot.conf
boot {
        generate grub
        default "Funtoo Linux genkernel"
        timeout 3 
}

"Funtoo Linux" {
        kernel bzImage[-v]
        # params += nomodeset
}

"Funtoo Linux genkernel" {
        kernel kernel[-v]
        initrd initramfs[-v]
        params += real_root=auto 
        # params += nomodeset
} 
GRUBCONF

chroot /mnt/funtoo grub-install --no-floppy /dev/sda
chroot /mnt/funtoo boot-update

#Root password, needed since we're a two step installation
chroot /mnt/funtoo /bin/bash <<ENDCHROOT
passwd<<EOF
vagrant
vagrant
EOF
ENDCHROOT

#create vagrant user with password set to vagrant
chroot /mnt/funtoo groupadd -r vagrant
chroot /mnt/funtoo groupadd rvm
chroot /mnt/funtoo useradd -m -r vagrant -g vagrant -G wheel,rvm -p '$1$MPmczGP9$1SeNO4bw5YgiEJuo/ZkWq1' -c "Added by vagrant, veewee basebox creation"
chroot /mnt/funtoo rc-update add sshd default

#Allow external ssh
echo 'sshd:ALL' > /mnt/funtoo/etc/hosts.allow
echo 'ALL:ALL' > /mnt/funtoo/etc/hosts.deny

#Configure Sudo
chroot /mnt/funtoo emerge -u sudo
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /mnt/funtoo/etc/sudoers


#Installing vagrant keys
chroot /mnt/funtoo emerge -u wget 

echo "creating vagrant ssh keys"
VAGRANTID=$(grep vagrant /mnt/funtoo/etc/passwd | cut -d ":" -f 3,4)
mkdir /mnt/funtoo/home/vagrant/.ssh
chmod 700 /mnt/funtoo/home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O /mnt/funtoo/home/vagrant/.ssh/authorized_keys
chmod 600 /mnt/funtoo/home/vagrant/.ssh/authorized_keys
chown -R ${VAGRANTID} /mnt/funtoo/home/vagrant/.ssh

/bin/cp -f /root/.vbox_version /mnt/funtoo/home/vagrant/.vbox_version
/bin/cp -f /etc/vagrant_box_build_time /mnt/funtoo/etc/vagrant_box_build_time
chown -R ${VAGRANTID} /mnt/funtoo/home/vagrant/.vbox_version

# veewee validate uses password authentication
sed -i -e 's:PasswordAuthentication no:PasswordAuthentication yes:' /mnt/funtoo/etc/ssh/sshd_config

#Get an editor going
chroot /mnt/funtoo emerge -u vim
echo "EDITOR=/usr/bin/vim" > /mnt/funtoo/etc/env.d/99editor
chroot /mnt/funtoo env-update


cd /
/etc/rc.d/network stop
umount /mnt/funtoo/{boot,proc,dev}
umount /mnt/funtoo

reboot
