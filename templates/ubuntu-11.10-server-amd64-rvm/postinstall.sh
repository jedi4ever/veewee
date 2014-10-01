#!/bin/bash

if [ -f .veewee_params ]
then
  . .veewee_params
fi

# postinstall.sh created from Mitchell's official lucid32/64 baseboxes

date > /etc/vagrant_box_build_time

# Apt-install various things necessary for guest additions,
# etc., and remove optional things to trim down the machine.
aptitude -y update
aptitude -y safe-upgrade
aptitude -y install linux-headers-$(uname -r)

# Setup sudo to allow no-password sudo for "admin"
cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers

# Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' -O authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

# Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

rm VBoxGuestAdditions_$VBOX_VERSION.iso

# Install Ruby Version Manager
curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer -o /tmp/rvm-installer
chmod +x /tmp/rvm-installer
/tmp/rvm-installer stable

# Enable RVM for all users
(cat <<'EOP'
[[ -s "/usr/local/rvm/scripts/rvm" ]] && source "/usr/local/rvm/scripts/rvm"
EOP
) > /etc/profile.d/rvm.sh
echo "gem: --no-rdoc --no-ri" > /home/vagrant/.gemrc
chown vagrant:vagrant /home/vagrant/.gemrc

# Install Ruby using RVM
echo "Installing Ruby 1.9.2 as default ruby"
bash -c '
 source /etc/profile
 rvm install 1.9.2-p290
 rvm alias create default ruby-1.9.2-p290
 rvm use 1.9.2-p290 --default

 echo "Installing default RubyGems"
 gem install --no-rdoc --no-ri chef puppet ruby-debug-ide19 ruby-debug-base19 ruby-debug19 rails mysql mysql2'

# Make default user member of RVM group
usermod -a -G rvm vagrant

# Remove items used for building, since they aren't needed anymore
aptitude -y remove linux-headers-$(uname -r)
apt-get -y autoremove
apt-get -y clean
aptitude -y autoclean

# Zero out the free space to save space in the final image:
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Removing leftover leases and persistent rules
echo "cleaning up dhcp leases"
rm /var/lib/dhcp3/*

# Make sure Udev doesn't block our network
# http://6.ptmc.org/?p=164
echo "cleaning up udev rules"
rm /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

echo "Adding a 2 sec delay to the interface up, to make the dhclient happy"
echo "pre-up sleep 2" >> /etc/network/interfaces
exit
