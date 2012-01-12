#http://chrisadams.me.uk/2010/05/10/setting-up-a-centos-base-box-for-development-and-testing-with-vagrant/

date > /etc/vagrant_box_build_time

yum -y install gcc make gcc-c++ ruby zlib-devel openssl-devel readline-devel sqlite-devel perl

cat > /etc/yum.repos.d/puppetlabs.repo << EOM
[puppetlabs]
name=puppetlabs
baseurl=http://yum.puppetlabs.com/el/6/products/\$basearch
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

yum -y install dkms puppet facter ruby-devel rubygems
yum -y clean all
rm /etc/yum.repos.d/{puppetlabs,epel}.repo

gem install --no-ri --no-rdoc chef

# Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
echo "Installing authorized keys for vagrant user"
curl --silent -L -o authorized_keys https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
chown -R vagrant /home/vagrant/.ssh

# Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp

#force install the correct kernel headers for this version of centos
echo "Retrieving and installing kernel-devel-2.6.32-71.el6.x86_64.rpm "
curl --silent -L -o kernel-devel-2.6.32-71.el6.x86_64.rpm http://vault.centos.org/6.0/os/x86_64/Packages/kernel-devel-2.6.32-71.el6.x86_64.rpm
sudo rpm -ivh --force kernel-devel-2.6.32-71.el6.x86_64.rpm

echo "Retrieving and installing VBoxGuestAdditions"
curl --silent -L -o VBoxGuestAdditions_$VBOX_VERSION.iso http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

rm VBoxGuestAdditions_$VBOX_VERSION.iso

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

dd if=/dev/zero of=/tmp/clean || rm /tmp/clean

exit
