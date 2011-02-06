#http://adrianbravo.tumblr.com/post/644860401

#Updating the box
apt-get -y update
#apt-get -y dist-upgrade
apt-get clean

#Setting up sudo
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers

#Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' -O authorized_keys
chown -R vagrant /home/vagrant/.ssh

#Installing the virtualbox guest additions
# This will not work... We need to figure out some way to get the current VBox version
apt-get -y install linux-headers-$(uname -r) build-essential \
                   zlib1g-dev libssl-dev libreadline5-dev
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

rm -f $VBOX_ISO $0

apt-get -y autoremove
exit
