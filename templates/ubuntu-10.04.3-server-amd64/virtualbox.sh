# Installing the virtualbox guest additions
if test -f /home/veewee/.vbox_version
then
	VBOX_VERSION=$(cat /home/veewee/.vbox_version)
	cd /tmp
	wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
	mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
	sh /mnt/VBoxLinuxAdditions.run
	umount /mnt
	rm VBoxGuestAdditions_$VBOX_VERSION.iso
fi

