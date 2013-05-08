#Installing the virtualbox guest additions
FILE_VBOX_VERSION=/home/vagrant/.vbox_version

if test -f $FILE_VBOX_VERSION
then
  VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
  if test -f VBoxGuestAdditions_$VBOX_VERSION.iso
  then
    cp VBoxGuestAdditions_$VBOX_VERSION.iso /tmp
    cd /tmp
  else
    cd /tmp
    wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
  fi
  mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
  yes|sh /mnt/VBoxLinuxAdditions.run
  umount /mnt

  rm VBoxGuestAdditions_$VBOX_VERSION.iso
fi
