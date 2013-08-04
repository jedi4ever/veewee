if test -f /home/vagrant/.vbox_version ; then
# Installing the virtualbox guest additions
mount /dev/sr1 /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
fi
