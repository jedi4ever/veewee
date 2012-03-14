#http://chrisadams.me.uk/2010/05/10/setting-up-a-centos-base-box-for-development-and-testing-with-vagrant/
#kernel source is needed for vbox additions

date > /etc/vagrant_box_build_time

yum -y install gcc bzip2 make

#yum -y update
#yum -y upgrade

yum -y install gcc-c++ zlib-devel openssl-devel readline-devel sqlite3-devel

yum -y erase wireless-tools gtk2 libX11 hicolor-icon-theme avahi freetype bitstream-vera-fonts


yum -y clean all

#Installing ruby
if [ -x /usr/bin/ruby ]; then
        echo Ruby is already installed : `ruby --version`
else
        wget http://rubyforge.org/frs/download.php/71096/ruby-enterprise-1.8.7-2010.02.tar.gz
        tar xzvf ruby-enterprise-1.8.7-2010.02.tar.gz
        ./ruby-enterprise-1.8.7-2010.02/installer -a /opt/ruby --no-dev-docs --dont-install-useful-gems
        echo 'PATH=$PATH:/opt/ruby/bin'> /etc/profile.d/rubyenterprise.sh
        rm -rf ./ruby-enterprise-1.8.7-2010.02/
        rm ruby-enterprise-1.8.7-2010.02.tar.gz
fi

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
#force install the correct kernel headers for this version of centos
PACKAGE_KERNEL_DEVEL="kernel-devel-"`uname -r`
RPM_KERNEL_DEVEL=$PACKAGE_KERNEL_DEVEL".i686.rpm"
URL_KERNEL_DEVEL=http://vault.centos.org/5.6/os/i386/CentOS/$RPM_KERNEL_DEVEL
echo Retrieving and installing $PACKAGE_KERNEL_DEVEL from $URL_KERNEL_DEVEL
curl --silent -L -o $RPM_KERNEL_DEVEL $URL_KERNEL_DEVEL
sudo rpm -ivh --force $RPM_KERNEL_DEVEL
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

rm VBoxGuestAdditions_$VBOX_VERSION.iso


sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

#poweroff -h

exit
