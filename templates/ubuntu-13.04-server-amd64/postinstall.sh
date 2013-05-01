date > /etc/vagrant_box_build_time

apt-get -y update
apt-get -y upgrade
apt-get -y install linux-headers-$(uname -r) build-essential
apt-get -y install zlib1g-dev libssl-dev libreadline-gplv2-dev libyaml-dev
apt-get -y install vim
apt-get -y install dkms
apt-get -y install nfs-common
apt-get clean

VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxGuestAdditions_$VBOX_VERSION.iso
umount /mnt

rm VBoxGuestAdditions_$VBOX_VERSION.iso

groupadd -r admin
usermod -a -G admin vagrant
cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers

adduser --system --group --home /var/lib/puppet puppet

cd /tmp

wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p392.tar.gz
tar xvzf ruby-1.9.3-p392.tar.gz
cd ruby-1.9.3-p392
./configure --prefix=/opt/ruby
make
make install
cd ..
rm -rf ruby-1.9.3-p392
rm ruby-1.9.3-p392.tar.gz

wget http://production.cf.rubygems.org/rubygems/rubygems-2.0.3.tgz
tar xzf rubygems-2.0.3.tgz
cd rubygems-2.0.3
/opt/ruby/bin/ruby setup.rb
cd ..
rm -rf rubygems-2.0.3
rm rubygems-2.0.3.tgz

/opt/ruby/bin/gem install chef --no-ri --no-rdoc
/opt/ruby/bin/gem install puppet --no-ri --no-rdoc

echo 'PATH=$PATH:/opt/ruby/bin/' > /etc/profile.d/vagrantruby.sh

mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

apt-get -y autoremove

dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

echo "cleaning up dhcp leases"
rm /var/lib/dhcp/*

echo "cleaning up udev rules"
rm /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

echo "pre-up sleep 2" >> /etc/network/interfaces
exit
