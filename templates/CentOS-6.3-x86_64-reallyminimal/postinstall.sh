#!/bin/bash

## responsible for installing all packages, configuring vagrant stuff

# http://chrisadams.me.uk/2010/05/10/setting-up-a-centos-base-box-for-development-and-testing-with-vagrant/
# http://vagrantup.com/v1/docs/base_boxes.html
set -e
set -u
set -x

date > /etc/vagrant_box_build_time

# remember path to this script so we can delete it later
_this_script=$( readlink -e $0 )

# clean up after kickstart
rm -f /tmp/ks-script*

# Make ssh faster by not waiting on DNS
echo "UseDNS no" >> /etc/ssh/sshd_config

# install puppet
echo "installing puppet"
rpm -i http://yum.puppetlabs.com/el/6/products/i386/puppetlabs-release-6-6.noarch.rpm

# puppet requires the 'puppet' group
# http://projects.puppetlabs.com/issues/9862
/usr/sbin/groupadd -r puppet
yum -y install puppet

yum -y erase puppetlabs-release

# http://wiki.centos.org/HowTos/Virtualization/VirtualBox/CentOSguest
# epel required to install dkms
rpm -i http://mirrors.kernel.org/fedora-epel/6/i386/epel-release-6-8.noarch.rpm

# dkms required for allowing VBox additions to survive kernel upgrades
yum -y install dkms

yum -y erase epel-release

## all RPMs installed after this timestamp can be removed
pre_install_ts=$( date '+%s' ); sleep 1

# kernel source is needed for vbox additions
yum -y install \
    gcc kernel-devel-$(uname -r) \
    gcc-c++ zlib-devel openssl-devel readline-devel \
    make bzip2 which perl

## install chef
echo "installing chef"
gem install chef --no-ri --no-rdoc

#Installing the virtualbox guest additions
VBOX_VERSION=$( cat ~vagrant/.vbox_version )
cd /tmp
mount -o loop ~vagrant/VBoxGuestAdditions_${VBOX_VERSION}.iso /mnt
sh /mnt/VBoxLinuxAdditions.run --nox11
umount /mnt

rm ~vagrant/VBoxGuestAdditions_${VBOX_VERSION}.iso

# Installing vagrant keys
mkdir ~vagrant/.ssh
cd ~vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys

chown -R vagrant:vagrant ~vagrant/.ssh
chmod 700 ~vagrant/.ssh
chmod 600 ~vagrant/.ssh/*

# Customize the message of the day
echo 'Welcome to your Vagrant-built virtual machine.' > /etc/motd

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
sed -i "s/^\(.*env_keep = \"\)/\1PATH SSH_AUTH_SOCK /" /etc/sudoers

## almost there.  remove stuff we don't need, but keep dkms
(
    rpm -qa --queryformat='%{INSTALLTIME} %{NAME}\n' | egrep -v dkms | \
        while read inst_ts pkg_name; do
            if [ ${inst_ts} -ge ${pre_install_ts} ]; then
                echo ${pkg_name}
            fi
        done

    rpm -qa --queryformat='%{NAME}\n' | \
        fgrep -- -firmware | \
        egrep -v kernel-firmware

    echo bitstream-vera-fonts
    echo iscsi-initiator-utils
    echo system-config-firewall-base
    echo make

) | xargs yum -y erase 

yum -y clean --enablerepo='*' all

# return to level 3 as the default
sed -i 's/^id:.*$/id:3:initdefault:/' /etc/inittab

## CLEAN ALL THE THINGS!
# http://vstone.eu/reducing-vagrant-box-size/

## bash history
unset HISTFILE
[ -f /root/.bash_history ] && rm /root/.bash_history
[ -f ~vagrant/.bash_history ] && rm ~vagrant/.bash_history
 
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

echo "please reboot"
exit 0

