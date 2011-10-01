date > /etc/vagrant_box_build_time

#Updating the box
apt-get -y update
apt-get -y install linux-headers-$(uname -r) build-essential
apt-get -y install zlib1g-dev libssl-dev libreadline5-dev
apt-get clean

#Setting up sudo
cp /etc/sudoers /etc/sudoers.orig
sed -i -e 's/vagrant ALL=(ALL) ALL/vagrant ALL=NOPASSWD:ALL/g' /etc/sudoers

#Installing ruby
apt-get -y install ruby ruby1.8-dev libopenssl-ruby1.8 rdoc ri irb make g++ libshadow-ruby1.8

# Install RubyGems 1.7.2
wget http://production.cf.rubygems.org/rubygems/rubygems-1.7.2.tgz
tar xzf rubygems-1.7.2.tgz
cd rubygems-1.7.2
/usr/bin/ruby setup.rb
cd ..
rm -rf rubygems-1.7.2*
ln -sfv /usr/bin/gem1.8 /usr/bin/gem

# Installing chef & Puppet
/usr/bin/gem install chef --no-ri --no-rdoc
/usr/bin/gem install puppet --no-ri --no-rdoc

#Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

#Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
yes|sh /mnt/VBoxLinuxAdditions.run
umount /mnt

apt-get -y remove linux-headers-$(uname -r) build-essential
apt-get -y autoremove

rm VBoxGuestAdditions_$VBOX_VERSION.iso

# Zero out the free space to save space in the final image:
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Removing leftover leases and persistent rules
echo "cleaning up dhcp leases"
rm /var/lib/dhcp3/*

echo "Adding a 2 sec delay to the interface up, to make the dhclient happy"
echo "pre-up sleep 2" >> /etc/network/interfaces
exit
