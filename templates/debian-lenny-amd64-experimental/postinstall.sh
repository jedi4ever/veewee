#http://adrianbravo.tumblr.com/post/644860401

#Updating the box
apt-get -y update
apt-get -y install linux-headers-$(uname -r) build-essential \
                   zlib1g-dev libssl-dev libreadline5-dev
apt-get clean

#Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
VBOX_ISO=/tmp/vboxga.iso
if [ ! -f $VBOX_ISO ]; then
  wget -qO$VBOX_ISO http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
fi
mount -o loop $VBOX_ISO /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

apt-get -y remove linux-headers-$(uname -r) build-essential \
                  zlib1g-dev libssl-dev libreadline5-dev
apt-get -y autoremove

rm -f $VBOX_ISO $0
exit
