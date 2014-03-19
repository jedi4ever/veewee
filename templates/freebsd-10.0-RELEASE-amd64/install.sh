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
virtio_load="YES"
virtio_pci_load="YES"
virtio_blk_load="YES"
if_vtnet_load="YES"
virtio_balloon_load="YES"
EOT

export ASSUME_ALWAYS_YES=YES
pkg bootstrap
pkg2ng

mv -vf /usr/local/etc/pkg.conf.sample /usr/local/etc/pkg.conf

# Install binary packages versions of dependencies
pkg install -y sudo bash-static

# Set up user accounts
zfs create tank/root/home
zfs create tank/root/home/vagrant
echo "vagrant" | pw -V /etc useradd vagrant -h 0 -s /usr/local/bin/bash -G wheel -d /home/vagrant -c "Vagrant User"

chown -R vagrant:vagrant /home/vagrant

# Enable passwordless sudo
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /usr/local/etc/sudoers

# Reboot
reboot

