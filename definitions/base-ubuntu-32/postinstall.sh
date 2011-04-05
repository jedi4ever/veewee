#http://adrianbravo.tumblr.com/post/644860401

#Updating the box
apt-get -y update
#apt-get -y upgrade
apt-get -y remove apparmor
apt-get -y install linux-headers-$(uname -r) build-essential
apt-get -y install zlib1g-dev libssl-dev libreadline5-dev
# Installing additional ruby packages for chef + nfs sharing
# See https://redmine.dkd.de/issues/9492
apt-get -y install ruby ruby-dev libopenssl-ruby rdoc ri irb build-essential wget ssl-cert
apt-get -y install openssl
apt-get -y install nfs-common
apt-get clean

#Setting up sudo
cp /etc/sudoers /etc/sudoers.orig
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers

#Installing ruby
REE_VERSION="ruby-enterprise_1.8.7-2011.03_i386_ubuntu10.04"
wget http://rubyenterpriseedition.googlecode.com/files/${REE_VERSION}.deb
dpkg -i ${REE_VERSION}.deb
rm ${REE_VERSION}.deb


#Installing chef & Puppet
/opt/ruby/bin/gem install chef --no-ri --no-rdoc
/opt/ruby/bin/gem install puppet --no-ri --no-rdoc

# Install additional languages 
# @see https://redmine.dkd.de/issues/8615
locale-gen de_DE.UTF-8
locale-gen de_DE ISO-8859-1
locale-gen de_DE@euro ISO-8859-15

#Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' -O authorized_keys
chown -R vagrant /home/vagrant/.ssh
# Adding user to group www-data to fix issues with (non-nfs) shared folders
# https://redmine.dkd.de/issues/9072
usermod -G vagrant,admin,www-data vagrant

#INstalling the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
#INstalling the virtualbox guest additions
cd /tmp
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso   
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

rm VBoxGuestAdditions_$VBOX_VERSION.iso
exit
