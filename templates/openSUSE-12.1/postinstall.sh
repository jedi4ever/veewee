#
# postinstall.sh
#

date > /etc/vagrant_box_build_time

# install vagrant key
echo -e "\ninstall vagrant key ..."
mkdir -m 0700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate -O authorized_keys https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant.users /home/vagrant/.ssh

# update sudoers
echo -e "\nupdate sudoers ..."
echo -e "\n# added by veewee/postinstall.sh" >> /etc/sudoers
echo -e "vagrant ALL=(ALL) NOPASSWD: ALL\n" >> /etc/sudoers

# speed-up remote logins
echo -e "\nspeed-up remote logins ..."
echo -e "\n# added by veewee/postinstall.sh" >> /etc/ssh/sshd_config
echo -e "UseDNS no\n" >> /etc/ssh/sshd_config

# install chef and puppet
echo -e "\ninstall chef and puppet ..."
gem install chef --no-ri --no-rdoc
gem install puppet --no-ri --no-rdoc

# remove zypper locks, preventing installation of additional packages,
# present because of the autoinst <software><remove-packages>
echo -e "\nremove zypper package locks ..."
rm -f /etc/zypp/locks

# install the virtualbox guest additions
echo -e "\ninstall the virtualbox guest additions ..."
zypper --non-interactive remove `rpm -qa virtualbox-guest-*`
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
#wget http://192.168.178.10/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm -f VBoxGuestAdditions_$VBOX_VERSION.iso

echo -e "\nall done.\n"
exit
