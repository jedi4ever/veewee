#http://chrisadams.me.uk/2010/05/10/setting-up-a-centos-base-box-for-development-and-testing-with-vagrant/

date > /etc/vagrant_box_build_time

fail()
{
  echo "FATAL: $*"
  exit 1
}

# Make ssh faster by not waiting on DNS
echo "UseDNS no" >> /etc/ssh/sshd_config

#kernel source is needed for vbox additions
yum -y install gcc bzip2 make kernel-devel-`uname -r`
#yum -y update
#yum -y upgrade

yum -y install gcc-c++ zlib-devel openssl-devel readline-devel sqlite3-devel
yum -y erase gtk2 libX11 hicolor-icon-theme avahi freetype bitstream-vera-fonts
yum -y clean all

#Installing ruby
cd /tmp
wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p180.tar.gz || fail "Could not download Ruby source"
tar xzvf ruby-1.9.2-p180.tar.gz 
cd ruby-1.9.2-p180
./configure
make && make install
cd /tmp
rm -rf /tmp/ruby-1.9.2-p180
rm /tmp/ruby-1.9.2-p180.tar.gz
ln -s /usr/local/bin/ruby /usr/bin/ruby # Create a sym link for the same path
ln -s /usr/local/bin/gem /usr/bin/gem # Create a sym link for the same path

#Installing chef & Puppet
echo "Installing chef and puppet"
/usr/local/bin/gem install chef --no-ri --no-rdoc || fail "Could not install chef"
/usr/local/bin/gem install puppet --no-ri --no-rdoc || fail "Could not install puppet"

#Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chown -R vagrant /home/vagrant/.ssh

#Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

rm VBoxGuestAdditions_$VBOX_VERSION.iso

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
sed -i "s/^\(.*env_keep = \"\)/\1PATH /" /etc/sudoers

#poweroff -h

exit
