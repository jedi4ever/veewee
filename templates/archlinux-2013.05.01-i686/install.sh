pacstrap /mnt base base-devel openssh syslinux virtualbox-guest-utils netctl #  

genfstab /mnt >> /mnt/etc/fstab # generate fstab

cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist # copy mirror list to new system

arch-chroot /mnt # chroot to /mnt
# bash # bash at /mnt

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen # add en_US locale
locale-gen # generate locale

ln -sf /usr/share/zoneinfo/Europe/Zurich /etc/localtime # set zurich time zone
echo "arch32" >> /etc/hostname # set the hostname

# make sure ssh is allowed
echo "sshd:	ALL" > /etc/hosts.allow

# and everything else isn't
echo "ALL:	ALL" > /etc/hosts.deny

# set root password
passwd<<EOF
vagrant
vagrant
EOF

# add vagrant user and set password
useradd -m -G wheel -r vagrant
passwd -d vagrant
passwd vagrant<<EOF
vagrant
vagrant
EOF

systemctl enable dhcpcd.service # enable dhcp deamon
systemctl enable sshd.service # enable ssh deamon
systemctl enable vboxservice.service # enable vitualbox guest additions

# add users to th virtualbox group
gpasswd -a root vboxsf
gpasswd -a vagrant vboxsf

# cofigure bootload 
cp /usr/lib/syslinux/menu.c32 /boot/syslinux/ # boot menu
cp /usr/lib/syslinux/hdt.c32 /boot/syslinux/  # hardware test
cp /usr/lib/syslinux/reboot.c32 /boot/syslinux/ # reboot
cp /usr/lib/syslinux/poweroff.com /boot/syslinux/ # poweroff 
extlinux --install /boot/syslinux
dd conv=notrunc bs=440 count=1 if=/usr/lib/syslinux/gptmbr.bin of=/dev/sda

# update pacman
pacman -Syy
pacman -S --noconfirm pacman

pacman -S --noconfirm ruby

# upgrade pacman db
pacman-db-upgrade
pacman -Syy

# create puppet group
groupadd puppet

# install some packages
pacman -S --noconfirm git

# downgrade gem to 1.8.25 for chef
gem update --system 1.8.25

gem install --no-user-install --no-ri --no-rdoc chef facter

cd /tmp
git clone https://github.com/puppetlabs/puppet.git
cd puppet
ruby install.rb --bindir=/usr/bin --sbindir=/sbin

# clean out pacman cache
pacman -Scc<<EOF
y
y
EOF

exit # exit chroot
sgdisk /dev/sda --attributes=:1:set:2 # update partition table

reboot