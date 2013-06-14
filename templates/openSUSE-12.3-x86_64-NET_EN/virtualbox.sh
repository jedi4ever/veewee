if
  test -f .vbox_version
then
  mount -o loop VBoxGuestAdditions_$(cat .vbox_version).iso /mnt
  yes|sh /mnt/VBoxLinuxAdditions.run
  umount /mnt

  # Start the newly build driver
  /etc/init.d/vboxadd start

  # Make a temporary mount point
  mkdir /tmp/veewee-validation

  # Test mount the veewee-validation
  mount -t vboxsf veewee-validation /tmp/veewee-validation
fi
