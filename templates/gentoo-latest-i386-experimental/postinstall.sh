#!/bin/bash

date > /etc/vagrant_box_build_time

#Based on http://www.gentoo.org/doc/en/gentoo-x86-quickinstall.xml

#Partition the disk
#This assumes a predefined layout - customize to your own liking

#/boot -> /dev/sda1
#swap -> /dev/sda2
#root -> /dev/sda3

sfdisk --force /dev/sda <<EOF
# partition table of /dev/sda
unit: sectors

/dev/sda1 : start=     2048, size=   409600, Id=83
/dev/sda2 : start=   411648, size=  2097152, Id=82
/dev/sda3 : start=  2508800, size= 18257920, Id=83
/dev/sda4 : start=        0, size=        0, Id= 0
EOF

sleep 2

#Format the /boot
mke2fs /dev/sda1

#Main partition /
mke2fs -j /dev/sda3

#Format the swap and use it
mkswap /dev/sda2
swapon /dev/sda2

#Mount the new disk
mkdir /mnt/gentoo
mount /dev/sda3 /mnt/gentoo
mkdir /mnt/gentoo/boot
mount /dev/sda1 /mnt/gentoo/boot
cd /mnt/gentoo

#Note: we retry as sometimes mirrors fail to have the files

#Download a stage3 archive
while true; do
	wget ftp://distfiles.gentoo.org/gentoo/releases/x86/current-stage3/stage3-i686-*.tar.bz2 && > gotstage3
        if [ -f "gotstage3" ]
        then
		break
	else
		echo "trying in 2seconds"
		sleep 2
        fi
done
tar xjpf stage3*

#Download Portage snapshot
cd /mnt/gentoo/usr
while true; do
	wget http://distfiles.gentoo.org/snapshots/portage-latest.tar.bz2 && > gotportage
        if [ -f "gotportage" ]
        then
		break
	else
		echo "trying in 2seconds"
		sleep 2
	fi
done

tar xjf portage-lat*

#Chroot
cd /
mount -t proc proc /mnt/gentoo/proc
mount --rbind /dev /mnt/gentoo/dev
cp -L /etc/resolv.conf /mnt/gentoo/etc/
echo "env-update && source /etc/profile" | chroot /mnt/gentoo /bin/bash -

# Get the kernel sources
echo "emerge gentoo-sources" | chroot /mnt/gentoo /bin/bash -

# We will use genkernel to automate the kernel compilation
# http://www.gentoo.org/doc/en/genkernel.xml
echo "emerge grub" | chroot /mnt/gentoo /bin/bash -
echo "emerge genkernel" | chroot /mnt/gentoo /bin/bash -
echo "genkernel --bootloader=grub --real_root=/dev/sda3 --no-splash --install all" | chroot /mnt/gentoo /bin/bash -

cat <<EOF | chroot /mnt/gentoo /bin/bash -
cat <<FSTAB > /etc/fstab
/dev/sda1   /boot     ext2    noauto,noatime     1 2
/dev/sda3   /         ext3    noatime            0 1
/dev/sda2   none      swap    sw                 0 0
FSTAB
EOF


#We need some things to do here
#Network
cat <<EOF | chroot /mnt/gentoo /bin/bash -
cd /etc/conf.d
echo 'config_eth0=( "dhcp" )' >> net
#echo 'dhcpd_eth0=( "-t 10" )' >> net
#echo 'dhcp_eth0=( "release nodns nontp nois" )' >> net
rc-update add net.eth0 default
#Module?
rc-update add sshd default
EOF

#Root password

# Cron & Syslog
echo "emerge syslog-ng vixie-cron" | chroot /mnt/gentoo sh -
echo "rc-update add syslog-ng default" | chroot /mnt/gentoo sh -
echo "rc-update add vixie-cron default" | chroot /mnt/gentoo sh -

#Get an editor going
echo "emerge vim" | chroot /mnt/gentoo sh -

#Allow external ssh
echo "echo 'sshd:ALL' > /etc/hosts.allow" | chroot /mnt/gentoo sh -
echo "echo 'ALL:ALL' > /etc/hosts.deny" | chroot /mnt/gentoo sh -

#create vagrant user  / password vagrant
chroot /mnt/gentoo useradd -m -r vagrant -p '$1$MPmczGP9$1SeNO4bw5YgiEJuo/ZkWq1'

#Configure Sudo
chroot /mnt/gentoo emerge sudo
echo "echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers" | chroot /mnt/gentoo sh -

#Installing vagrant keys
chroot /mnt/gentoo emerge wget 

echo "creating vagrant ssh keys"
chroot /mnt/gentoo mkdir /home/vagrant/.ssh
chroot /mnt/gentoo chmod 700 /home/vagrant/.ssh
chroot /mnt/gentoo cd /home/vagrant/.ssh
chroot /mnt/gentoo wget --no-check-certificate 'http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' -O /home/vagrant/.ssh/authorized_keys
chroot /mnt/gentoo chmod 600 /home/vagrant/.ssh/authorized_keys
chroot /mnt/gentoo chown -R vagrant /home/vagrant/.ssh

#This could be done in postinstall
#reboot

#get some ruby running
chroot /mnt/gentoo emerge git curl gcc automake  m4
chroot /mnt/gentoo emerge libiconv readline zlib openssl curl git libyaml sqlite libxslt
echo "bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)"| chroot /mnt/gentoo /bin/bash -
echo "/usr/local/rvm/bin/rvm install ruby-1.8.7 "| chroot /mnt/gentoo sh -
echo "/usr/local/rvm/bin/rvm use ruby-1.8.7 --default "| chroot /mnt/gentoo sh -

#Installing chef & Puppet
echo ". /usr/local/rvm/scripts/rvm ; gem install chef --no-ri --no-rdoc"| chroot /mnt/gentoo sh -
echo ". /usr/local/rvm/scripts/rvm ; gem install puppet --no-ri --no-rdoc"| chroot /mnt/gentoo sh -


echo "adding rvm to global bash rc"
echo "echo '. /usr/local/rvm/scripts/rvm' >> /etc/bash/bash.rc" | chroot /mnt/gentoo sh -

/bin/cp -f /root/.vbox_version /mnt/gentoo/home/vagrant/.vbox_version
VBOX_VERSION=$(cat /root/.vbox_version)

#Kernel headers
chroot /mnt/gentoo emerge linux-headers

#Installing the virtualbox guest additions
cat <<EOF | chroot /mnt/gentoo /bin/bash -
cd /tmp
mkdir /mnt/vbox
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt/vbox
sh /mnt/vbox/VBoxLinuxAdditions.run
#umount /mnt/vbox
#rm VBoxGuestAdditions_$VBOX_VERSION.iso
EOF

echo "sed -i 's:^DAEMONS\(.*\))$:DAEMONS\1 rc.vboxadd):' /etc/rc.conf" | chroot /mnt/gentoo sh -

exit
cd /
umount /mnt/gentoo/{proc,sys,dev}
umount /mnt/gentoo

reboot
