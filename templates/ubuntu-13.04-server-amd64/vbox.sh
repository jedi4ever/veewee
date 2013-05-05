VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxGuestAdditions_$VBOX_VERSION.iso
umount /mnt
rm VBoxGuestAdditions_$VBOX_VERSION.iso
