# postinstall.sh created from Mitchell's official lucid32/64 baseboxes

date > /etc/vagrant_box_build_time

# Apt-install various things necessary for Ruby, guest additions,
# etc., and remove optional things to trim down the machine.
apt-get -y update
apt-get -y upgrade
apt-get -y install linux-headers-$(uname -r) build-essential
apt-get -y install zlib1g-dev libssl-dev libreadline-gplv2-dev
apt-get -y install vim
apt-get clean

# Installing the virtualbox guest additions
apt-get -y install dkms
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

rm VBoxGuestAdditions_$VBOX_VERSION.iso

# Setup sudo to allow no-password sudo for "admin"
groupadd -r admin
usermod -a -G admin vagrant
cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers

# Install NFS client
apt-get -y install nfs-common

# Install Ruby from packages
apt-get -y install ruby rubygems

echo mysql-server-5.5 mysql-server/root_password password vagrant | debconf-set-selections
echo mysql-server-5.5 mysql-server/root_password_again password vagrant | debconf-set-selections

apt-get -y install mysql-server-5.5

apt-get -y install php5 php5-cli php5 libapache2-mod-php5 postgresql sqlite3

apt-get -y install curl
apt-get -y install mongodb
apt-get -y install mongodb-dev libpq-dev libmagickcore-dev libmagickwand-dev
apt-get -y install git
apt-get -y install patch
apt-get -y install build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion pkg-config




apt-get -y install libmysqlclient-dev


# Installing chef & Puppet
# gem install chef --no-ri --no-rdoc
# gem install puppet --no-ri --no-rdoc

# Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

# Install Ruby Version Manager
wget --no-check-certificate  https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer -O /tmp/rvm-installer
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
echo "Installing Ruby 1.9.3 as default ruby"
bash -c '
 source /etc/profile
 rvm --force reinstall 1.9.2
 rvm --force reinstall 1.9.3
 rvm --default use 1.9.3

 echo "Installing default RubyGems"
 gem install --no-rdoc --no-ri chef puppet ruby-debug-ide19 ruby-debug-base19 ruby-debug19 mysql mysql2 sqlite3 pg mongo mongoid therubyracer rails'

# Make default user member of RVM group
usermod -a -G rvm vagrant




# Remove items used for building, since they aren't needed anymore
# apt-get -y remove linux-headers-$(uname -r) build-essential
# apt-get -y autoremove

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
