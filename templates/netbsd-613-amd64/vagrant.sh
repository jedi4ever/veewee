PATH=/usr/bin:/bin:/usr/pkg/bin:/usr/sbin:/sbin:/usr/pkg/sbin

# Set up Vagrant.
ntpdate pool.ntp.org
date > /etc/vagrant_box_build_time

# Make Vagrant user environment.
mkdir /home
useradd -m -g=uid -G wheel -p `pwhash vagrant` -s /usr/pkg/bin/bash vagrant

# SSH public key for vagrant user.
mkdir -m 700 /home/vagrant/.ssh
curl -ksL http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub > /home/vagrant/.ssh/authorized_keys
chown -R vagrant.vagrant /home/vagrant/.ssh
