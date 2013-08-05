#!/bin/bash

# Wanted multi-user RVM (ruby version manager) setup.  It got really hacky.
# Couldn't get the su command to work in the chroot so split the install into two
# phases, one in chroot, and the second phase in the installed kernel.
# Ruby's RVM needs to be installed by a user not root for multi-user use.
# All this would go away in single user install of RVM

# A bit better security, but still your root and vagrant accounts are wide open!
echo -e "PermitRootLogin no\nAllowUsers vagrant" >> /etc/ssh/sshd_config

# Cron & Syslog
emerge -u --oneshot metalog vixie-cron
rc-update add metalog default
rc-update add vixie-cron default

#Kernel headers
emerge -u --oneshot sys-kernel/linux-headers

if test -f /home/vagrant/.vbox_version ; then
#Installing the virtualbox guest additions
emerge app-emulation/virtualbox-guest-additions
rc-update add virtualbox-guest-additions default
fi

# Get ruby and rvm all setup...
emerge -u --oneshot git curl gcc automake autoconf m4
emerge -u --oneshot libiconv readline zlib openssl libyaml sqlite libxslt

# Clean up portage
rm -rf /usr/portage/distfiles/*
rm /stage3*.tar.xz

# What a PITA, wanted to get a shared RVM setup, but that can't be installed by root
# Starting to feel like a matryoshka doll...
# Setup so you can SSH into the vagrant account
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant' -O /tmp/sshkey
chmod 600 /tmp/sshkey

cat <<SSHCONF > /tmp/sshvagrant
Host me
  HostName 127.0.0.1
  User vagrant
  Port 22
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile /tmp/sshkey
  IdentitiesOnly yes
SSHCONF

cat <<GEMINST > /tmp/sshgems
echo -e "\n***\n*** My id is yuck ***\n***\n"

# Lots of problems if you install as root so we'll use sudo like to docs describe
sudo bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer )
sudo env-update
source /etc/profile

# Install ruby and gems into rvm
rvm install 1.8.7
rvm use 1.8.7 --default
rvm gemset create global
rvm use @global

#Installing chef & puppet
gem install chef
gem install puppet

# Cleanup
sudo chmod 655 /tmp/sshkey
sudo rm /tmp/ssh*

echo -e "\n***\n*** Chef and Puppet installed in RVM ***\n***\n"
GEMINST

chmod 755 /tmp/sshgems
sed -i -e 's,yuck,$(id),' /tmp/sshgems
ssh -F /tmp/sshvagrant me /tmp/sshgems

# Sometimes you don't get out of the SSH session.  Think the EOF bails out both
# the ssh login with the vagrant account and the veewee login with the root
# account.  So we put the RVM stuff last and its no issue.

echo -e "\n***\n*** SURVIVED SSH EOF! ***\n***\n"
