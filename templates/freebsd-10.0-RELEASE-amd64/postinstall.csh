#!/bin/csh -x
# NB: at the point when this script is run, vagrant's shell is csh

set echo

# Set root password
echo "vagrant" | pw -V /etc usermod root -h 0

#Set the time correctly
ntpdate -v -b in.pool.ntp.org

date > /etc/vagrant_box_build_time

# reduce the ports we extract to a minimum
cat >> /etc/portsnap.conf << EOT
REFUSE accessibility arabic archivers astro audio benchmarks biology cad
REFUSE converters chinese comms databases deskutils distfiles devel dns editors finance french
REFUSE ftp games german graphics hebrew hungarian irc japanese java korean
REFUSE lang mail math multimedia misc net net-im net-mgmt net-p2p news packages palm
REFUSE polish portuguese print russian science shells sysutils textproc ukrainian
REFUSE vietnamese www x11 x11-clocks x11-drivers x11-fm x11-fonts x11-servers
REFUSE x11-themes x11-toolkits x11-wm
EOT

# get new ports
portsnap --interactive fetch extract

cd /usr/ports/ports-mgmt/pkg
make -DBATCH install

# Install binary packages versions of dependencies
pkg install -y sudo bash rubygem-chef puppet portupgrade perl5 kBuild yasm

cat >> /etc/make.conf << EOT
WITH_ETCSYMLINK="YES"
EOT

# Install certificates so we can fetch from GitHub
cd /usr/ports/security/ca_root_nss
make install -DBATCH

#Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
fetch -am -o authorized_keys 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub'
chown -R vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh

# As sharedfolders are not in defaults ports tree
# We will use vagrant via NFS
# Enable NFS
echo 'rpcbind_enable="YES"' >> /etc/rc.conf
echo 'nfs_server_enable="YES"' >> /etc/rc.conf
echo 'mountd_flags="-r"' >> /etc/rc.conf

# Enable passwordless sudo
echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /usr/local/etc/sudoers
# Restore correct su permissions
# I'll leave that up to the reader :)

# disable X11 because vagrants are (usually) headless
cat >> /etc/make.conf << EOT
WITHOUT_X11="YES"
EOT

# Fetch base system files for building Virtualbox OSE Additions
fetch -o /tmp/src.txz http://ftp.freebsd.org/pub/FreeBSD/releases/amd64/10.0-RELEASE/src.txz
fetch -o /tmp/lib32.txz http://ftp.freebsd.org/pub/FreeBSD/releases/amd64/10.0-RELEASE/lib32.txz

# Extract into /usr/src and /usr/lib32
tar -k -C / -xf /tmp/src.txz
tar -k -C / -xf /tmp/lib32.txz

cd /usr/ports/emulators/virtualbox-ose-additions
make -DBATCH package clean

cp /usr/local/etc/pkg.conf.sample /usr/local/etc/pkg.conf

# undo our customizations
sed -i '' -e '/^REFUSE /d' /etc/portsnap.conf
# sed -i '' -e '/^WITHOUT_X11/d' /etc/make.conf

echo 'vboxdrv_load="YES"' >> /boot/loader.conf
echo 'vboxnet_enable="YES"' >> /etc/rc.conf
echo 'vboxguest_enable="YES"' >> /etc/rc.conf
echo 'vboxservice_enable="YES"' >> /etc/rc.conf

# sed -i.bak -Ee 's|/dev/ada?|/dev/vtbd|' /etc/fstab
echo 'ifconfig_vtnet0_name="em0"' >> /etc/rc.conf
echo 'ifconfig_vtnet1_name="em1"' >> /etc/rc.conf
echo 'ifconfig_vtnet2_name="em2"' >> /etc/rc.conf
echo 'ifconfig_vtnet3_name="em3"' >> /etc/rc.conf

pw groupadd vboxusers
pw groupmod vboxusers -m vagrant

#Bash needs to be the shell for tests to validate
pw usermod vagrant -s /usr/local/bin/bash

#Cleanup
rm /home/vagrant/VBoxGuestAdditions*
rm -r /var/db/portsnap/snap
rm -r /usr/ports
rm -r /usr/src
rm -rf /tmp/*
rm /home/vagrant/postinstall.csh


# Zero out all data to reduce box size
dd if=/dev/zero of=/tmp/ZEROES bs=1M
rm /tmp/ZEROES

cat /dev/null > /root/.history

echo "=============================================================================="
echo "NOTE: FreeBSD - Vagrant"
echo "When using this basebox you need to do some special stuff in your Vagrantfile"
echo "1) Enable HostOnly network"
echo "	 config.vm.network ...."
echo "2) Use nfs instead of shared folders"
echo '		config.vm.share_folder("v-root", "/vagrant", ".", :nfs => true)'
echo "============================================================================="

exit
