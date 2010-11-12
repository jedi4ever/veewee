#http://chrisadams.me.uk/2010/05/10/setting-up-a-centos-base-box-for-development-and-testing-with-vagrant/
#kernel source is needed for vbox additions

yum -y install gcc bzip2 make kernel-devel-`uname -r`

#yum -y update
#yum -y upgrade

yum -y install gcc-c++ zlib-devel openssl-devel readline-devel sqlite3-devel     
      
#Installing ruby
wget http://rubyforge.org/frs/download.php/71096/ruby-enterprise-1.8.7-2010.02.tar.gz
tar xzvf ruby-enterprise-1.8.7-2010.02.tar.gz
./ruby-enterprise-1.8.7-2010.02/installer -a /opt/ruby
echo 'PATH=$PATH:/opt/ruby/bin/'> /etc/profile.d/rubyenterprise.sh

#Installing chef
/opt/ruby/bin/gem install chef

#Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 600 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' -O authorized_keys
chown -R vagrant /home/vagrant/.ssh

#INstalling the virtualbox guest additions
cd /tmp
wget http://download.virtualbox.org/virtualbox/3.2.8/VBoxGuestAdditions_3.2.8.iso   
mount -o loop VBoxGuestAdditions_3.2.8.iso /mnt
sh /mnt/VBoxLinuxAdditions-x86.run
umount /mnt

poweroff -h

exit