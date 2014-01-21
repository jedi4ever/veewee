#!/bin/sh -x

sleep 10
# Enable required services
cat >> /etc/rc.conf << EOT
hostname="${NAME}"
ifconfig_em0="dhcp"
sshd_enable="YES"
EOT

# Tune and boot from zfs
cat >> /boot/loader.conf << EOT
vm.kmem_size="200M"
vm.kmem_size_max="200M"
vfs.zfs.arc_max="40M"
vfs.zfs.vdev.cache.size="5M"
EOT

# Set up user accounts
zfs create tank/root/home
zfs create tank/root/home/vagrant
echo "vagrant" | pw -V /etc useradd vagrant -h 0 -s csh -G wheel -d /home/vagrant -c "Vagrant User"

chown 1001:1001 /home/vagrant

# Reboot
reboot

