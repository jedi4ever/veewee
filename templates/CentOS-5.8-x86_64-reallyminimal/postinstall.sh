#!/bin/bash

## responsible for installing all packages, configuring vagrant stuff

# http://chrisadams.me.uk/2010/05/10/setting-up-a-centos-base-box-for-development-and-testing-with-vagrant/
# http://vagrantup.com/v1/docs/base_boxes.html
set -e
set -u
set -x

echo "$0 $(date)" >> /etc/vagrant_box_build_time

fail() {
    echo "FATAL: $*"
    exit 1
}

# remember path to this script so we can delete it later
_this_script=$( readlink -e $0 )

# clean up after kickstart
rm -f /tmp/ks-script*

# Make ssh faster by not waiting on DNS
echo "UseDNS no" >> /etc/ssh/sshd_config

echo "installing puppetlabs repo"
rpm -i http://yum.puppetlabs.com/el/5/products/i386/puppetlabs-release-5-6.noarch.rpm

## getting these errors because we're not installing docs. we'll have to ignore
## yum install's failed exit code.
##     install-info: 
##     No such file or directory for /usr/share/info/termcap.info.gz

# kernel source is needed for vbox additions
yum -y install \
    gcc kernel-devel-$(uname -r) \
    gcc-c++ zlib-devel openssl-devel readline-devel \
    make bzip2 which \
|| echo "ignored failed yum command"

# install puppet
echo "installing puppet"
# puppet requires the 'puppet' group
# http://projects.puppetlabs.com/issues/9862
/usr/sbin/groupadd -r puppet
yum -y install puppet

# we'll install chef, too, even though it probably won't be used
echo "installing chef"
yum -y install ruby-devel
gem install chef --no-ri --no-rdoc

#Installing vagrant keys
mkdir /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys

chown -R vagrant:vagrant /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
chmod 600 /home/vagrant/.ssh/*

# Customize the message of the day
echo 'Welcome to your Vagrant-built virtual machine.' > /etc/motd

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
sed -i "s/^\(.*env_keep = \"\)/\1PATH SSH_AUTH_SOCK /" /etc/sudoers

#Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp
mount -o loop /home/vagrant/VBoxGuestAdditions_${VBOX_VERSION}.iso /mnt
sh /mnt/VBoxLinuxAdditions.run --nox11
umount /mnt

rm /home/vagrant/VBoxGuestAdditions_${VBOX_VERSION}.iso

## almost there.  remove stuff we don't need
rpm -qa | grep -- -devel | xargs yum -y erase

yum -y erase \
    gtk2 \
    hicolor-icon-theme \
    freetype \
    bitstream-vera-fonts \
    kernel-devel \
    kernel-headers \
    cups-libs libgomp libhugetlbfs libtiff libjpeg libpng

yum -y clean --enablerepo='*' all

# return to level 3 as the default
sed -i 's/^id:.*$/id:3:initdefault:/' /etc/inittab

## allow yum to install docs again
sed -i '/^tsflags/d' /etc/yum.conf

## CLEAN ALL THE THINGS!
# http://vstone.eu/reducing-vagrant-box-size/

## bash history
unset HISTFILE
[ -f /root/.bash_history ] && rm /root/.bash_history
[ -f /home/vagrant/.bash_history ] && rm /home/vagrant/.bash_history
 
## log files
find /var/log -type f | while read f; do echo -ne '' > $f; done;

echo "whiteout root"
count=$( df --sync -kP / | tail -n1  | awk '{print $4}' )
let count--
dd if=/dev/zero of=/whitespace bs=1024 count=${count}
rm /whitespace
 
echo "whiteout /boot"
count=$( df --sync -kP /boot | tail -n1 | awk '{print $4}' )
let count--
dd if=/dev/zero of=/boot/whitespace bs=1024 count=${count}
rm /boot/whitespace

echo "whiteout swap"
swappart=$( cat /proc/swaps | tail -n1 | awk '{print $1}' )
/sbin/swapoff ${swappart}
dd if=/dev/zero of=${swappart} || echo "ignored failed exit code from dd"
/sbin/mkswap ${swappart}
/sbin/swapon ${swappart}

rm -f ${_this_script}

reboot

exit
