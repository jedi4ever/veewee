#
# postinstall.sh
#

date > /etc/vagrant_box_build_time

# remove zypper package locks
rm -f /etc/zypp/locks

# install vagrant key
mkdir -pm 700 /home/vagrant/.ssh
curl -Lo /home/vagrant/.ssh/authorized_keys 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub'
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant: /home/vagrant/.ssh

# install VBoxGuestAdditions
if
  test -f .vbox_version
then
  mount -o loop VBoxGuestAdditions_$(cat .vbox_version).iso /mnt
  yes|sh /mnt/VBoxLinuxAdditions.run
  umount /mnt

  # Start the newly build driver
  /etc/init.d/vboxadd start

  # Make a temporary mount point
  mkdir /tmp/veewee-validation

  # Test mount the veewee-validation
  mount -t vboxsf veewee-validation /tmp/veewee-validation
fi

# set vagrant sudo
printf "%b" "
# added by veewee/postinstall.sh
vagrant ALL=(ALL) NOPASSWD: ALL
" >> /etc/sudoers

# speed-up remote logins
printf "%b" "
# added by veewee/postinstall.sh
UseDNS no
" >> /etc/ssh/sshd_config

# disable gem docs
echo "gem: --no-ri --no-rdoc" >/etc/gemrc

# install chef
#gem install chech
