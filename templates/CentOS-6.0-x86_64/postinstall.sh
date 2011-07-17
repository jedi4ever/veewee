#http://chrisadams.me.uk/2010/05/10/setting-up-a-centos-base-box-for-development-and-testing-with-vagrant/

cat > /etc/yum.repos.d/stahna.repo << EOM
[stahnma]
name=stahnma
baseurl=http://stahnma.fedorapeople.org/puppetlabs/6/\$basearch
enabled=1
gpgcheck=0
EOM

cat > /etc/yum.repos.d/epel.repo << EOM
[epel]
name=epel
baseurl=http://download.fedoraproject.org/pub/epel/6/\$basearch
enabled=1
gpgcheck=0
EOM

#yum -y install gcc bzip2 make kernel-devel-`uname -r` gcc-c++ zlib-devel openssl-devel readline-devel sqlite3-devel puppet facter
yum -y install puppet facter
yum -y erase wireless-tools gtk2 libX11 hicolor-icon-theme avahi freetype bitstream-vera-fonts
yum -y clean all

# Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' -O authorized_keys
chown -R vagrant /home/vagrant/.ssh

# Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm VBoxGuestAdditions_$VBOX_VERSION.iso

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

dd if=/dev/zero of=/tmp/clean || rm /tmp/clean

exit
