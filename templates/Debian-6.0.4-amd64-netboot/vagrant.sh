# Installing the virtualbox guest additions
if test -f /home/veewee/.vbox_version
then
  date > /etc/vagrant_box_build_time

  # Create the user vagrant with password vagrant
  useradd -G admin -p $(perl -e'print crypt("vagrant", "vagrant")') -m -s /bin/bash -N vagrant

  # Install vagrant keys
  mkdir -p /home/vagrant/.ssh
  chmod 700 /home/vagrant/.ssh
  cd /home/vagrant/.ssh
  curl -Lo /home/vagrant/.ssh/authorized_keys \
    'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub'
  chmod 0600 /home/vagrant/.ssh/authorized_keys
  chown -R vagrant:vagrant /home/vagrant/.ssh

  # Customize the message of the day
  echo 'Welcome to your Vagrant-built virtual machine.' > /var/run/motd

  # Install NFS client
  apt-get -y install nfs-common

fi

