#!/bin/bash

date > /etc/vagrant_box_build_time

#Based on http://www.funtoo.org/wiki/Funtoo_Linux_Installation

#Partition the disk
#This assumes a predefined layout - customize to your own liking

#/boot -> /dev/sda1   200M, need to skip a few meg for new GPT instead of old MBR
#swap  -> /dev/sda2   1.5G
#root  -> /dev/sda3   Rest of space and bootable

sfdisk --force /dev/sda -uM<<EOF
2,200,L
,1500,S
,,L,*
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


#We need some things to do here

#Root password
chroot /mnt/funtoo /bin/bash <<ENDCHROOT
passwd<<EOF
vagrant
vagrant
EOF
ENDCHROOT

#create vagrant user  / password vagrant
chroot /mnt/funtoo useradd -m -r vagrant -p '$1$MPmczGP9$1SeNO4bw5YgiEJuo/ZkWq1'

# Cron & Syslog
chroot /mnt/funtoo emerge metalog vixie-cron
chroot /mnt/funtoo rc-update add metalog default
chroot /mnt/funtoo rc-update add vixie-cron default

#Get an editor going
chroot /mnt/funtoo emerge vim

#Allow external ssh
echo "echo 'sshd:ALL' > /etc/hosts.allow" | chroot /mnt/funtoo /bin/bash -
echo "echo 'ALL:ALL' > /etc/hosts.deny" | chroot /mnt/funtoo /bin/bash -

#Configure Sudo
chroot /mnt/funtoo emerge sudo
echo "echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers" | chroot /mnt/funtoo /bin/bash -

#Installing vagrant keys
chroot /mnt/funtoo emerge wget 

echo "creating vagrant ssh keys"
chroot /mnt/funtoo mkdir /home/vagrant/.ssh
chroot /mnt/funtoo chmod 700 /home/vagrant/.ssh
chroot /mnt/funtoo cd /home/vagrant/.ssh
chroot /mnt/funtoo wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O /home/vagrant/.ssh/authorized_keys
chroot /mnt/funtoo chmod 600 /home/vagrant/.ssh/authorized_keys
chroot /mnt/funtoo chown -R vagrant /home/vagrant/.ssh

#This could be done in postinstall
#reboot

#get some ruby running
chroot /mnt/funtoo emerge git curl gcc automake  m4
chroot /mnt/funtoo emerge libiconv readline zlib openssl curl git libyaml sqlite libxslt
echo "bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)"| chroot /mnt/funtoo /bin/bash -
echo "/usr/local/rvm/bin/rvm install ruby-1.8.7 "| chroot /mnt/funtoo /bin/bash -
echo "/usr/local/rvm/bin/rvm use ruby-1.8.7 --default "| chroot /mnt/funtoo /bin/bash -

#Installing chef & Puppet
echo ". /usr/local/rvm/scripts/rvm ; gem install chef --no-ri --no-rdoc"| chroot /mnt/funtoo /bin/bash -
echo ". /usr/local/rvm/scripts/rvm ; gem install puppet --no-ri --no-rdoc"| chroot /mnt/funtoo /bin/bash -


echo "adding rvm to global bash rc"
echo "echo '. /usr/local/rvm/scripts/rvm' >> /etc/bash/bash.rc" | chroot /mnt/funtoo /bin/bash -

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

echo "sed -i 's:^DAEMONS\(.*\))$:DAEMONS\1 rc.vboxadd):' /etc/rc.conf" | chroot /mnt/funtoo /bin/bash -

exit
cd /
umount /mnt/funtoo/{proc,sys,dev}
umount /mnt/funtoo

reboot
