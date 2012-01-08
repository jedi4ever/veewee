# set pkg path for users
echo " "
echo " Setting PKG_PATH for users "
echo " "
echo " export  PKG_PATH=http://ftp.plig.net/pub/OpenBSD/`uname -r`/packages/`arch -s`/ " >> /root/.profile
echo " export  PKG_PATH=http://ftp.plig.net/pub/OpenBSD/`uname -r`/packages/`arch -s`/ ">> /home/vagrant/.profile

# giving root & vagrant bash as shell
echo " "
echo " Giving root/vagrant bash as a shell "
echo " "
usermod -s /usr/local/bin/bash vagrant
usermod -s /usr/local/bin/bash root

# install wget/curl/bash/vim and its dependencies
echo " "
echo " Installing needed packages "
echo " "
export  PKG_PATH=http://ftp.plig.net/pub/OpenBSD/`uname -r`/packages/`arch -s`/ 
pkg_add wget curl bash vim-7.3.154p1-no_x11 rsync bzip2 ngrep
pkg_add ruby-1.8.7.352p1
pkg_add ruby-gems
 ln -sf /usr/local/bin/gem18 /usr/local/bin/gem

 ln -sf /usr/local/bin/ruby18 /usr/local/bin/ruby
 ln -sf /usr/local/bin/erb18 /usr/local/bin/erb
 ln -sf /usr/local/bin/irb18 /usr/local/bin/irb
 ln -sf /usr/local/bin/rdoc18 /usr/local/bin/rdoc
 ln -sf /usr/local/bin/ri18 /usr/local/bin/ri
 ln -sf /usr/local/bin/testrb18 /usr/local/bin/testrb

pkg_add ruby-iconv
pkg_add ruby-puppet-2.7.1

gem install chef --no-ri --no-rdoc

/etc/rc.d/sendmail stop

# Create puppet user/group
echo " "
echo " Creating puppet user / group "
echo " "
groupadd puppet
useradd -g puppet -d /var/lib/puppet -s /usr/bin/false puppet


# install the ports system for who wants to use it
echo " "
echo " Installing the ports system ! "
echo " "
cd /tmp
wget http://ftp.plig.net/pub/OpenBSD/5.0/ports.tar.gz
cd /usr
sudo tar xzf /tmp/ports.tar.gz

# sudo
# Defaults requiretty is not present in the sudoers file
# env_keep I'll leave it as it is since user's path is same or more comprehensive than root's path
echo " "
echo " Setting sudo to work with vagrant "
echo " "
echo "# Uncomment to allow people in group wheel to run all commands without a password" >> /etc/sudoers
echo "%wheel        ALL=(ALL) NOPASSWD: SETENV: ALL" >> /etc/sudoers

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

echo
echo "Post-install done"
exit 0
