#!/bin/sh

date > /etc/vagrant_box_build_time

# Install VirtualBox extensions.

VBOX_VERSION=$(cat /home/vagrant/.vbox_version)

cd /tmp
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop,ro VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm VBoxGuestAdditions_$VBOX_VERSION.iso

exit 0

# EOF
