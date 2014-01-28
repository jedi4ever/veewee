# Set up Vagrant.

date > /etc/vagrant_box_build_time

# Create puppet user/group
echo " "
echo " Creating puppet user / group "
echo " "
groupadd puppet
useradd -g puppet -d /var/lib/puppet -s /usr/bin/false puppet

# Add groups puppet and chef
groupadd puppet
groupadd chef

# setup the vagrant key
# you can replace this key-pair with your own generated ssh key-pair
echo " "
echo " Setting the vagrant ssh pub key "
echo " "
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
chown vagrant.vagrant /home/vagrant/.ssh
touch /home/vagrant/.ssh/authorized_keys
curl -sL http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub > /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown vagrant.vagrant /home/vagrant/.ssh/authorized_keys
