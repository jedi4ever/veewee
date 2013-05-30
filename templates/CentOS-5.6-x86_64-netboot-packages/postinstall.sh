# based on http://chrisadams.me.uk/2010/05/10/setting-up-a-centos-base-box-for-development-and-testing-with-vagrant/
# but with all the source building moved to packages & puppet focussed

date > /etc/vagrant_box_build_time

fail()
{
  echo "FATAL: $*"
  exit 1
}

# Make ssh faster by not waiting on DNS
echo "UseDNS no" >> /etc/ssh/sshd_config

#kernel source is needed for vbox additions
yum -y install gcc bzip2 make 
# kernel-devel-`uname -r` is now installed in the KS to ensure we get matching kernel & kernel-devel on the first boot
#yum -y update
#yum -y upgrade

yum -y install gcc-c++ zlib-devel openssl-devel readline-devel sqlite3-devel
yum -y erase gtk2 libX11 hicolor-icon-theme avahi freetype bitstream-vera-fonts

# puppet 
rpm -ivh http://yum.puppetlabs.com/el/5/products/i386/puppetlabs-release-5-6.noarch.rpm
yum -y install puppet-2.6.10

# chef, via gem
#yum install ruby ruby-devel ruby-ri ruby-rdoc ruby-shadow gcc gcc-c++ automake autoconf make curl dmidecode
#gem install chef --no-ri --no-rdoc

# chef, via rpms (I'm not sure how sane this is, it installs lots of rubygem-xxx packages)
rpm -Uvh http://rbel.co/rbel5
yum -y install rubygem-chef

# clean up yum meta data cache
yum -y clean all

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

# Zero out the free space to save space in the final image:
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

exit
