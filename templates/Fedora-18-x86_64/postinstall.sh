#!/bin/sh

date > /etc/vagrant_box_build_time

VBOX_VERSION=$(cat /home/vagrant/.vbox_version)

# Must exclude kernel for now. Otherwise, kernel gets upgraded before reboot,
# but VirtualBox tools get compiled against the old kernel, so the fresh
# image will refuse to start under Vagrant.
yum -y update --exclude kernel*

yum -y install \
  ruby \
  ruby-devel \
  puppet \
  rubygems \
  rubygem-bunny \
  rubygem-erubis \
  rubygem-highline \
  rubygem-json \
  rubygem-mime-types \
  rubygem-net-ssh \
  rubygem-polyglot \
  rubygem-rest-client \
  rubygem-systemu \
  rubygem-treetop \
  rubygem-uuidtools \
  wget \
  tar \
  bzip2

cd /tmp
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop,ro VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm VBoxGuestAdditions_$VBOX_VERSION.iso

gem install chef --no-rdoc --no-ri

exit

# EOF
