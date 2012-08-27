#Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)

if test -f $VBOX_VERSION
  cd /tmp
  wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
  mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
  yes|sh /mnt/VBoxLinuxAdditions.run
  umount /mnt

  apt-get -y remove linux-headers-$(uname -r) build-essential
  apt-get -y autoremove

  rm VBoxGuestAdditions_$VBOX_VERSION.iso
fi
