#!/bin/sh

date > /etc/vagrant_box_build_time

VBOX_VERSION=$(cat /home/vagrant/.vbox_version)

yum -y install \
  dkms \
  gcc \
  make \
  ruby \
  ruby-devel \
  rubygems \

yum clean all

mount /dev/cdrom1 /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
restorecon -R /opt/VBoxGuestAdditions-${VBOX_VERSION}

gem install chef puppet --no-rdoc --no-ri

exit

# EOF
