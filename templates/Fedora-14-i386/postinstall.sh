#http://chrisadams.me.uk/2010/05/10/setting-up-a-centos-base-box-for-development-and-testing-with-vagrant/
#kernel source is needed for vbox additions

date > /etc/vagrant_box_build_time

yum -y install gcc bzip2 make patch kernel-devel-`uname -r`

#yum -y update
#yum -y upgrade

yum -y install gcc-c++ zlib-devel openssl-devel readline-devel sqlite3-devel

# don't remove these because dependency removal will remove policycoreutils package and we should
# not care about these packages being installed in the first place
#yum -y erase  gtk2 libX11 hicolor-icon-theme avahi freetype bitstream-vera-fonts


yum -y clean all

#Installing ruby
wget http://rubyforge.org/frs/download.php/71096/ruby-enterprise-1.8.7-2010.02.tar.gz
tar xzvf ruby-enterprise-1.8.7-2010.02.tar.gz
./ruby-enterprise-1.8.7-2010.02/installer -a /opt/ruby --no-dev-docs --dont-install-useful-gems
echo 'PATH=$PATH:/opt/ruby/bin'> /etc/profile.d/rubyenterprise.sh
rm -rf ./ruby-enterprise-1.8.7-2010.02/
rm ruby-enterprise-1.8.7-2010.02.tar.gz

#Installing chef & Puppet
/opt/ruby/bin/gem install chef --no-ri --no-rdoc
/opt/ruby/bin/gem install puppet --no-ri --no-rdoc

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

#poweroff -h

exit
