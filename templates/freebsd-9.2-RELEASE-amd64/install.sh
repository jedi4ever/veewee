#!/bin/sh -x

# Credit: http://www.aisecure.net/2011/05/01/root-on-zfs-freebsd-current/

NAME=$1

# create disks
gpart create -s gpt ada0
gpart add -t freebsd-boot -l boot -b 40 -s 512K ada0
gpart bootcode -b /boot/pmbr -p /boot/gptboot -i 1 ada0
gpart add -t freebsd-ufs -l root -b 1M -s 2G ada0
gpart add -t freebsd-swap -l swap -s 512M ada0
gpart add -t freebsd-ufs -l var -s 1G ada0
gpart add -t freebsd-ufs -l tmp -s 512M ada0
gpart add -t freebsd-ufs -l usr -a 1M ada0

# create filesystems
newfs -U /dev/gpt/root
newfs -U /dev/gpt/var
newfs -U /dev/gpt/tmp
newfs -U /dev/gpt/usr

# mount the filesystems
mount /dev/gpt/root /mnt
mkdir /mnt/var && mount /dev/gpt/var /mnt/var
mkdir /mnt/tmp && mount /dev/gpt/tmp /mnt/tmp
mkdir /mnt/usr && mount /dev/gpt/usr /mnt/usr

# correct permissions
chmod 1777 /mnt/tmp
mkdir /mnt/var/tmp && chmod 1777 /mnt/var/tmp
cd /mnt && mkdir usr/home && ln -s usr/home home

# Install the OS
cd /usr/freebsd-dist
cat base.txz | tar --unlink -xpJf - -C /mnt
cat lib32.txz | tar --unlink -xpJf - -C /mnt
cat kernel.txz | tar --unlink -xpJf - -C /mnt
cat src.txz | tar --unlink -xpJf - -C /mnt

# Enable required services
cat >> /mnt/etc/rc.conf << EOT
hostname="${NAME}"
ifconfig_em0="dhcp"
sshd_enable="YES"
EOT

# Enable swap
cat >> /mnt/etc/fstab << EOT
/dev/gpt/swap none swap sw 0 0
/dev/gpt/root /    ufs  rw 1 1
/dev/gpt/var  /var ufs  rw 1 1
/dev/gpt/tmp  /tmp ufs  rw 1 1
/dev/gpt/usr  /usr ufs  rw 1 1
EOT

# Install a few requirements
touch /mnt/etc/resolv.conf
echo 'PermitRootLogin yes' >> /mnt/etc/ssh/sshd_config

# Set up user accounts
mkdir /mnt/usr/home/vagrant && chown 1001:1001 /mnt/home/vagrant
echo "vagrant" | pw -V /mnt/etc useradd vagrant -h 0 -s csh -G wheel -d /home/vagrant -c "Vagrant User"
echo "vagrant" | pw -V /mnt/etc usermod root -h 0

reboot
