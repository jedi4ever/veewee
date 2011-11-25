# install virtualbox guest additions
VBOX_VERSION=$(cat /root/.vbox_version)
cd /tmp
wget http://download.virtualbox.org/virtualbox/"$VBOX_VERSION"/VBoxGuestAdditions_"$VBOX_VERSION".iso
mount -o loop VBoxGuestAdditions_"$VBOX_VERSION".iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm VBoxGuestAdditions_"$VBOX_VERSION".iso

# host-only networking
cat >> /etc/rc.local <<EOF
# enable DHCP at boot on eth0
# See https://wiki.archlinux.org/index.php/Network#DHCP_fails_at_boot
dhcpcd -k eth0
dhcpcd -nd eth0
EOF

# clean out pacman cache
pacman -Scc<<EOF
y
y
EOF

# zero out the fs
dd if=/dev/zero of=/clean bs=4M|| rm /clean
dd if=/dev/zero of=/tmp/clean bs=4M|| rm /tmp/clean
dd if=/dev/zero of=/boot/clean bs=4M|| rm /boot/clean

# and the final reboot!
#reboot
