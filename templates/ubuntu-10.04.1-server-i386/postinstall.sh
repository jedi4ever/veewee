#http://adrianbravo.tumblr.com/post/644860401

#Updating the box
apt-get -y update
#apt-get -y upgrade
apt-get -y remove apparmor
apt-get -y install linux-headers-$(uname -r) build-essential
apt-get -y install zlib1g-dev libssl-dev libreadline5-dev
apt-get clean

#Setting up sudo
cp /etc/sudoers /etc/sudoers.orig
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers

#Installing ruby
wget http://rubyforge.org/frs/download.php/71096/ruby-enterprise-1.8.7-2010.02.tar.gz
tar xzvf ruby-enterprise-1.8.7-2010.02.tar.gz
./ruby-enterprise-1.8.7-2010.02/installer -a /opt/ruby
echo 'PATH=$PATH:/opt/ruby/bin/'> /etc/profile.d/rubyenterprise.sh

#Installing chef
/opt/ruby/bin/gem install chef

#Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' -O authorized_keys
chown -R vagrant /home/vagrant/.ssh

#INstalling the virtualbox guest additions
cd /tmp
wget http://download.virtualbox.org/virtualbox/3.2.8/VBoxGuestAdditions_3.2.8.iso   
mount -o loop VBoxGuestAdditions_3.2.8.iso /mnt
sh /mnt/VBoxLinuxAdditions-x86.run
umount /mnt

shutdown -h now
exit