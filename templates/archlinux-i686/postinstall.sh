#!/bin/bash

#https://wiki.archlinux.org/index.php/Install_from_Existing_Linux

#ARCH=x86_64
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
#This assumes a predefined layout - customize to your own liking

sfdisk --force /dev/sda <<EOF
# partition table of /dev/sda
unit: sectors

/dev/sda1 : start=     2048, size= 16777216, Id=83
/dev/sda2 : start= 16779264, size=  3987456, Id=82
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
#Customize to your own liking
sed -i 's/^#\(.*kangaroot.*\)/\1/' /etc/pacman.d/mirrorlist

# https://wiki.archlinux.org/index.php/Mirrors#List_by_speed
# pacman -S reflector
# export LC_ALL=C
# reflector -c Belgium -l 8 -r -o /etc/pacman.d/mirrorlist

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
echo "grep -v rootfs /proc/mounts > /etc/mtab" |chroot /newarch sh -
chroot /newarch grub-install /dev/sda
echo "cp -a /usr/lib/grub/i386-pc/* /boot/grub" | chroot /newarch sh -

#/boot/grub/menu.lst

echo "sed -i 's:^kernel\(.*\)$:kernel /boot/vmlinuz26 root=/dev/sda1 ro:' /boot/grub/menu.lst" | chroot /newarch sh -
echo "sed -i 's:^initrd\(.*\)$:initrd /boot/kernel26.img:' /boot/grub/menu.lst" | chroot /newarch sh -

#Configure ssh
chroot /newarch pacman --noconfirm -S openssh

#Still errors
echo "sed -i 's:^DAEMONS\(.*\))$:DAEMONS\1 sshd):' /etc/rc.conf" | chroot /newarch sh -
echo "echo 'sshd:ALL' > /etc/hosts.allow" | chroot /newarch sh -
echo "echo 'ALL:ALL' > /etc/hosts.deny" | chroot /newarch sh -




#Configure Sudo
chroot /newarch pacman --noconfirm -S sudo
echo "echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers" | chroot /newarch sh -

#create vagrant user  / password vagrant
chroot /newarch useradd -m -r vagrant -p '$1$MPmczGP9$1SeNO4bw5YgiEJuo/ZkWq1'

#get some ruby running
chroot /newarch pacman --noconfirm -S git curl gcc make
echo "bash < <( curl -L http://bit.ly/rvm-install-system-wide )"| chroot /newarch /bin/bash -
echo "/usr/local/bin/rvm install http://ftp.ruby-lang.org/pub/ruby/1.8/ruby-1.8.7-p334.tar.gz "| chroot /newarch sh -
echo "/usr/local/bin/rvm use http://ftp.ruby-lang.org/pub/ruby/1.8/ruby-1.8.7-p334.tar.gz --default "| chroot /newarch sh -


#Installing chef & Puppet
echo ". /usr/local/lib/rvm ; gem install chef --no-ri --no-rdoc"| chroot /newarch sh -
echo ". /usr/local/lib/rvm ; gem install puppet --no-ri --no-rdoc"| chroot /newarch sh -

#Installing vagrant keys
echo "creating vagrant ssh keys"
chroot /newarch mkdir /home/vagrant/.ssh
chroot /newarch chmod 700 /home/vagrant/.ssh
chroot /newarch cd /home/vagrant/.ssh
chroot /newarch wget --no-check-certificate 'http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' -O /home/vagrant/.ssh/authorized_keys
chroot /newarch chmod 600 /home/vagrant/.ssh/authorized_keys
chroot /newarch chown -R vagrant /home/vagrant/.ssh

echo "adding rvm to global bash rc"
echo "echo '. /usr/local/lib/rvm' >> /etc/bash/bash.rc" | chroot /newarch sh -

#https://wiki.archlinux.org/index.php/VirtualBox
#kernel pacman -S kernel26-headers
chroot /newarch pacman --noconfirm -S kernel26-headers
/bin/cp -f /root/.vbox_version /newarch/home/vagrant/.vbox_version
VBOX_VERSION=$(cat /root/.vbox_version)

#Installing the virtualbox guest additions
cat <<EOF | chroot /newarch /bin/bash -
cd /tmp
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm VBoxGuestAdditions_$VBOX_VERSION.iso
EOF

echo "sed -i 's:^DAEMONS\(.*\))$:DAEMONS\1 rc.vboxadd):' /etc/rc.conf" | chroot /newarch sh -


cd /
umount /newarch/{proc,sys,dev}
umount /newarch

reboot
