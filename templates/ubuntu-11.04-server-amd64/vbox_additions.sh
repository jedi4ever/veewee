# Installing the virtualbox guest additions
if test -e /home/vagrant/.vbox_version; then
	VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
	cd /tmp
	wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
	mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
	sh /mnt/VBoxLinuxAdditions.run
	umount /mnt

	rm VBoxGuestAdditions_$VBOX_VERSION.iso
fi
