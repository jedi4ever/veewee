#!/bin/bash

date > /etc/vagrant_box_build_time

# launch automated install
#format the partitioon
fdisk /dev/sda << EOF
n
p
1


w
y
EOF

mkfs.ext4 /dev/sda1

mount /dev/sda1 /mnt

pacstrap /mnt base base-devel ruby git glibc ruby wget glibc git pkg-config
fakeroot grub-bios

arch-chroot /mnt pacman -S grub-bios --noconfirm

genfstab -U /mnt >> /mnt/etc/fstab

# copy over the vbox version file
/bin/cp -f /root/.vbox_version /mnt/root/.vbox_version

# chroot into the new system
arch-chroot /mnt <<ENDCHROOT
# make sure network is up and a nameserver is available
dhcpcd eth0

# choose a mirror
sed -i 's/^#\(.*leaseweb.*\)/\1/' /etc/pacman.d/mirrorlist

# update pacman

# upgrade pacman db
pacman-db-upgrade
pacman -Syy

#make the initramfs
mkinitcpio -p linux
#install grub
grub-install --recheck --debug /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# sudo setup
# note: do not use tabs here, it autocompletes and borks the sudoers file
cat <<EOF > /etc/sudoers
root    ALL=(ALL)    ALL
%wheel    ALL=(ALL)    NOPASSWD: ALL
EOF

# set up user accounts
passwd<<EOF
vagrant
vagrant
EOF
useradd -m -G wheel -r vagrant
passwd -d vagrant
passwd vagrant<<EOF
vagrant
vagrant
EOF

# create puppet group
groupadd puppet

# make sure ssh is allowed
echo "sshd:	ALL" > /etc/hosts.allow

# and everything else isn't
echo "ALL:	ALL" > /etc/hosts.deny

# make sure sshd starts
sed -i 's:^DAEMONS\(.*\))$:DAEMONS\1 sshd):' /etc/rc.conf

# install mitchellh's ssh key
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh


# install some packages
gem install --no-ri --no-rdoc chef facter
cd /tmp
git clone https://github.com/puppetlabs/puppet.git
cd puppet
ruby install.rb --bindir=/usr/bin --sbindir=/sbin

# set up networking
[[ $PKGSRC == 'net' ]] && sed -i 's/^\(interface=*\)/\1eth0/' /etc/rc.conf

# leave the chroot
ENDCHROOT

# take down network to prevent next postinstall.sh from starting too soon
#/etc/rc.d/network stop

# and reboot!
reboot
