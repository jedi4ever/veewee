#!/bin/bash

date > /etc/vagrant_box_build_time

#Based on http://www.funtoo.org/wiki/Funtoo_Linux_Installation

#Partition the disk
# Gentoo live CD were using doesn't have gdisk and it looks 
# to be interactive like fdisk.  sfdisk is scribable but has issues.
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
cp /etc/resolv.conf ./etc/
echo "env-update && source /etc/profile" | chroot /mnt/funtoo /bin/bash -

# git installed from stage3 tarball
echo "emerge --sync" | chroot /mnt/funtoo /bin/bash -

# California dreamin
cd etc
rm -f localtime
ln -s ../usr/share/zoneinfo/America/Los_Angeles localtime
cd /mnt/funtoo

# get fstab defined
cat <<FSTABEOF > ./etc/fstab
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
echo "rc-update add dhcpcd default" | chroot /mnt/funtoo /bin/bash -

# Get the kernel sources
echo "sys-kernel/sysrescue-std-sources binary" >> ./etc/portage/package.use
echo "emerge sysrescue-std-sources" | chroot /mnt/funtoo /bin/bash -

# Fix a package blocker problem with the current stage3 tarball
#echo "emerge -u sysvinit" | chroot /mnt/funtoo /bin/bash -

# Make the disk bootable
echo "emerge boot-update" | chroot /mnt/funtoo /bin/bash -
echo 'MAKEOPTS="-j9"' >> /mnt/funtoo/etc/make.conf

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

echo "grub-install --no-floppy /dev/sda" | chroot /mnt/funtoo /bin/bash -
echo "boot-update" | chroot /mnt/funtoo /bin/bash -

#Root password, decided vagrant sudo was better, commented out
###chroot /mnt/funtoo /bin/bash <<ENDCHROOT
###passwd<<EOF
###vagrant
###vagrant
###EOF
###ENDCHROOT

#create vagrant user with password set to vagrant
chroot /mnt/funtoo groupadd -r vagrant
chroot /mnt/funtoo useradd -m -r vagrant -g vagrant -G wheel -p '$1$MPmczGP9$1SeNO4bw5YgiEJuo/ZkWq1' -c "Added by vagrant, veewee basebox creation"
chroot /mnt/funtoo rc-update add sshd default

# Cron & Syslog
chroot /mnt/funtoo emerge -u metalog vixie-cron
chroot /mnt/funtoo rc-update add metalog default
chroot /mnt/funtoo rc-update add vixie-cron default

#Get an editor going
chroot /mnt/funtoo emerge -u vim
echo "EDITOR=/usr/bin/vim" > /mnt/funtoo/etc/env.d/99editor

#Allow external ssh
echo "echo 'sshd:ALL' > /etc/hosts.allow" | chroot /mnt/funtoo /bin/bash -
echo "echo 'ALL:ALL' > /etc/hosts.deny" | chroot /mnt/funtoo /bin/bash -

#Configure Sudo
chroot /mnt/funtoo emerge -u sudo
echo "echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers" | chroot /mnt/funtoo /bin/bash -

#Installing vagrant keys
chroot /mnt/funtoo emerge -u wget 

echo "creating vagrant ssh keys"
chroot /mnt/funtoo mkdir /home/vagrant/.ssh
chroot /mnt/funtoo chmod 700 /home/vagrant/.ssh
chroot /mnt/funtoo cd /home/vagrant/.ssh
chroot /mnt/funtoo wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O /home/vagrant/.ssh/authorized_keys
chroot /mnt/funtoo chmod 600 /home/vagrant/.ssh/authorized_keys
chroot /mnt/funtoo chown -R vagrant /home/vagrant/.ssh

#get some ruby running, needed for veewee validate step
chroot /mnt/funtoo emerge -u git curl gcc automake autoconf m4
chroot /mnt/funtoo emerge -u libiconv readline zlib openssl libyaml sqlite libxslt
chroot /mnt/funtoo /bin/bash <<ENDRUBY
bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer )
. /usr/local/rvm/scripts/rvm 
rvm install ruby-1.8.7
rvm use ruby-1.8.7 --default

#Installing chef & Puppet
. /usr/local/rvm/scripts/rvm 
gem install chef
gem install puppet

usermod -G rvm vagrant
ENDRUBY

/bin/cp -f /root/.vbox_version /mnt/funtoo/home/vagrant/.vbox_version
VBOX_VERSION=$(cat /root/.vbox_version)

#Kernel headers
echo "emerge =sys-kernel/linux-headers-2.6.39" | chroot /mnt/funtoo /bin/bash -

#Installing the virtualbox guest additions
cat <<EOF | chroot /mnt/funtoo /bin/bash -
mkdir /etc/portage
cat <<KEYWORDSEOF > /etc/portage/package.keywords
=app-emulation/virtualbox-guest-additions-4.1.6-r1
KEYWORDSEOF
emerge =app-emulation/virtualbox-guest-additions-4.1.6-r1
rc-update add virtualbox-guest-additions default
EOF

rm -rf /mnt/funtoo/usr/portage/distfiles
mkdir /mnt/funtoo/usr/portage/distfiles
echo "chown portage:portage /usr/portage/distfiles" | chroot /mnt/funtoo /bin/bash -

# veewee validate uses password authentication
sed -i -e 's:PasswordAuthentication no:PasswordAuthentication yes:' /mnt/funtoo/etc/ssh/sshd_config

chroot /mnt/funtoo env-update

rm /mnt/funtoo/stage3*.tar.xz

exit
cd /
umount /mnt/funtoo/{proc,sys,dev}
umount /mnt/funtoo

reboot
