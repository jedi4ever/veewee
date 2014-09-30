#!/bin/sh

## Tag version
date > /etc/vagrant_box_build_time



## Add the opencsw package site
PATH=/usr/bin:/usr/sbin:$PATH
export PATH

yes|/usr/sbin/pkgadd -d http://mirror.opencsw.org/opencsw/pkgutil-`uname -p`.pkg all

# Uncomment this and pick a fast mirror from http://mirror.opencsw.org/status/
# echo "mirror=http://www.grangefields.co.uk/mirrors/csw/testing" >> /etc/opt/csw/pkgutil.conf

/opt/csw/bin/pkgutil -U

# get 'sudo'
/opt/csw/bin/pkgutil -y -i CSWsudo
chgrp 0 /etc/opt/csw/sudoers
ln -s /etc/opt/csw/sudoers /etc/sudoers
# get 'wget', 'GNU tar' and 'GNU sed' (also needed for Ruby)
/opt/csw/bin/pkgutil -y -i CSWwget CSWgtar CSWgsed CSWvim

# Add 'vagrant' to sudoers as well
test -f /etc/sudoers && grep -v "vagrant" "/etc/sudoers" 1>/dev/null 2>&1 && echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers



# Installing vagrant keys
mkdir ${HOME}/.ssh
chmod 700 ${HOME}/.ssh
cd ${HOME}/.ssh
/opt/csw/bin/wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chown -R vagrant:other ${HOME}/.ssh

# Speed up SSH by disabling DNS checks for clients
echo "LookupClientHostnames=no" >> /etc/ssh/sshd_config



## Ruby
/opt/csw/bin/pkgutil -y -i CSWgsed
/opt/csw/bin/pkgutil -y -i CSWruby18-gcc4 CSWruby18-dev CSWruby18
/opt/csw/bin/pkgutil -y -i CSWrubygems


#/opt/csw/bin/pkgutil -y -i CSWreadline
#/opt/csw/bin/pkgutil -y -i CSWzlib
#/opt/csw/bin/pkgutil -y -i CSWossldevel
#
## no solaris2.11 .... mkheaders here ! needs some fixing ??
## /opt/csw/gcc4/libexec/gcc/i386-pc-solaris2.10/4.3.3/install-tools/mkheaders
#/opt/csw/gcc4/libexec/gcc/i386-pc-solaris2.8/4.3.3/install-tools/mkheaders
#
#/opt/csw/sbin/alternatives --display rbconfig18
#/opt/csw/sbin/alternatives --set rbconfig18 /opt/csw/lib/ruby/1.8/i386-solaris2.9/rbconfig.rb.gcc4


## Fix the shells to include the /opt/csw and /usr/ucb directories
/opt/csw/bin/gsed -i -e 's#^\#PATH=.*$#PATH=/opt/csw/bin:/usr/sbin:/usr/bin:/usr/ucb#g' \
    -e 's#^\#SUPATH=.*$#SUPATH=/opt/csw/bin:/usr/sbin:/usr/bin:/usr/ucb#g' /etc/default/login
/opt/csw/bin/gsed -i -e 's#^\#PATH=.*$#PATH=/opt/csw/bin:/usr/sbin:/usr/bin:/usr/ucb#g' \
    -e 's#^\#SUPATH=.*$#SUPATH=/opt/csw/bin:/usr/sbin:/usr/bin:/usr/ucb#g' /etc/default/su



## Add the CSW libraries to the LD path
/usr/bin/crle -u -l /opt/csw/lib



## Installing the virtualbox guest additions (from the ISO)
#
VBOX_VERSION=`cat $HOME/.vbox_version`
cd /tmp
mkdir vboxguestmnt
mount -F hsfs -o ro `lofiadm -a $HOME/VBoxGuestAdditions_${VBOX_VERSION}.iso` /tmp/vboxguestmnt
cp /tmp/vboxguestmnt/VBoxSolarisAdditions.pkg /tmp/.
/usr/bin/pkgtrans VBoxSolarisAdditions.pkg . all
yes|/usr/sbin/pkgadd -d . SUNWvboxguest

umount /tmp/vboxguestmnt
lofiadm -d /dev/lofi/1



## Add loghost to /etc/hosts
/opt/csw/bin/gsed -i -e 's/localhost/localhost loghost/g' /etc/hosts



exit
