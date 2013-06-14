#
# postinstall.sh
#

date > /etc/vagrant_box_build_time

# remove zypper package locks
rm -f /etc/zypp/locks

# install required packages
packages=( gcc-c++ less make bison libtool ruby-devel vim )
zypper --non-interactive install --no-recommends --force-resolution ${packages[@]}

# install vagrant key
mkdir -pm 700 /home/vagrant/.ssh
curl -Lo /home/vagrant/.ssh/authorized_keys 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub'
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant: /home/vagrant/.ssh

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

# install chef and puppet
gem install chef
gem install puppet
