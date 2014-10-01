#!/bin/bash

if [ -f .veewee_params ]
then
  . .veewee_params
fi

# postinstall.sh created from Mitchell's official lucid32/64 baseboxes
# Extended by hedgehog consistent with the designation - alternate
# Provides:
# - 1.9.2-p180 (system installed as root, managed via update-alternatives)
# - 1.8.7-p352 (system installed as root, managed via update-alternatives)
# - 1.9.2-p180 (user installed as $VEEWEE_USER, managed via rvm)
#
# NOTES:
# - package update and upgrade are done in the preseed.cfg via the late_command
#

date > /etc/vagrant_box_build_time

set -x
#set -e

export DEBIAN_FRONTEND=noninteractive
export VEEWEE_USER="vagrant"
export VBOX_VERSION=$(cat /home/${VEEWEE_USER}/.vbox_version)

### Install Virtualbox guest additions
#
apt-get -y install dkms
cd /tmp
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

rm VBoxGuestAdditions_$VBOX_VERSION.iso

### Install packages
#
# Necessary for full Ruby 1.9.2, guest additions etc.
# Remove optional packages to trim VM size.
aptitude -y install python-software-properties
add-apt-repository "deb http://archive.canonical.com/ $(lsb_release -sc) partner"
apt-add-repository ppa:git-core/ppa
add-apt-repository ppa:byobu
aptitude -y purge apparmor apparmor-utils
aptitude -y install  byobu \
                     git-core


### Setup sudo
# Allow no-password sudo for "admin"
cp --archive /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers

### Install NFS client
#
# This is likely a Vagrant specific package so we keep it separated.
apt-get -y install nfs-common

### Install ruby 1.9.2-p180 from source
#
# Puppet 2.7 now supports 1.9.2
#
export RUBY_ROOT=/usr/bin/ruby
export RUBY_VER=1.9.2
export RUBY_BUILD_VER=${RUBY_VER}-p180

##########################################
#
# ENSURE System RUBY and RUBYGEM, etc variables point to non version paths
#
##########################################

cd /usr/local/src
wget ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-${RUBY_BUILD_VER}.tar.gz
tar -xzf ruby-${RUBY_BUILD_VER}.tar.gz
cd ruby-${RUBY_BUILD_VER}
./configure --with-ruby-version=$RUBY_BUILD_VER --prefix=/usr --program-suffix=$RUBY_BUILD_VER
/usr/bin/make
/usr/bin/make install
cd ..
rm -rf ./ruby-${RUBY_BUILD_VER}/
rm ruby-${RUBY_BUILD_VER}.tar.gz
echo 'gem: --no-ri --no-rdoc' >>~/.gemrc

DIR_PATH=`readlink -f "/usr/lib/ruby/gems/${RUBY_BUILD_VER}/bin"` # get rid of symlinks and get abs path
if test ! -d "${DIR_PATH}" ; then # now you're testing
    mkdir -p /usr/lib/ruby/gems/${RUBY_BUILD_VER}/bin
fi
RUBY_PRIORITY=`echo -n ${RUBY_VER}|sed -e 's/\.//g'`
update-alternatives \
  --install ${RUBY_ROOT} ruby ${RUBY_ROOT}${RUBY_BUILD_VER} ${RUBY_PRIORITY} \
  --slave   /usr/bin/ri   ri /usr/bin/ri${RUBY_BUILD_VER} \
  --slave   /usr/bin/erb  erb /usr/bin/erb${RUBY_BUILD_VER} \
  --slave   /usr/bin/rake rake /usr/bin/rake${RUBY_BUILD_VER} \
  --slave   /usr/bin/rdoc rdoc /usr/bin/rdoc${RUBY_BUILD_VER} \
  --slave   /usr/bin/gem  gem /usr/bin/gem${RUBY_BUILD_VER} \
  --slave   /usr/bin/testrb  testrb /usr/bin/testrb${RUBY_BUILD_VER} \
  --slave   /usr/bin/irb  irb /usr/bin/irb${RUBY_BUILD_VER} \
  --slave   /usr/lib/ruby/gems/bin gem-bin /usr/lib/ruby/gems/${RUBY_BUILD_VER}/bin \
  --slave   /usr/share/man/man1/ruby.1 ruby.1 \
            /usr/share/man/man1/ruby${RUBY_BUILD_VER}.1 \
  --slave   /usr/share/man/man1/erb.1 erb.1 \
            /usr/share/man/man1/erb${RUBY_BUILD_VER}.1 \
  --slave   /usr/share/man/man1/irb.1 irb.1 \
            /usr/share/man/man1/irb${RUBY_BUILD_VER}.1 \
  --slave   /usr/share/man/man1/ri.1 ri.1 \
            /usr/share/man/man1/ri${RUBY_BUILD_VER}.1 \
  --slave   /usr/share/man/man1/rake.1 rake.1 \
            /usr/share/man/man1/rake${RUBY_BUILD_VER}.1

### Update PATH
#
# Make binaries from gems installed to system Ruby(above) available system wide
#
echo PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/lib/ruby/gems/bin" >>/etc/environment
/usr/bin/gem update --system

### Install Chef & Puppet
#
/usr/bin/gem install chef --no-ri --no-rdoc
/usr/bin/gem install puppet --no-ri --no-rdoc

### Install Ruby 1.8.7
#
export RUBY_ROOT=/usr/bin/ruby
export RUBY_VER=1.8.7
export RUBY_BUILD_VER=${RUBY_VER}-p352

wget http://ftp.ruby-lang.org/pub/ruby/1.8/ruby-${RUBY_BUILD_VER}.tar.gz
tar -xzf ruby-${RUBY_BUILD_VER}.tar.gz
cd ruby-${RUBY_BUILD_VER}
./configure --with-ruby-version=$RUBY_BUILD_VER --prefix=/usr --program-suffix=$RUBY_BUILD_VER
/usr/bin/make
/usr/bin/make install
cd ..
rm -rf ruby-${RUBY_BUILD_VER}
rm ruby-${RUBY_BUILD_VER}.tar.gz

### Install RubyGems 1.8.5
#
wget http://rubyforge.org/frs/download.php/74954/rubygems-1.8.5.tgz
tar -xzf rubygems-1.8.5.tgz
cd rubygems-1.8.5
/usr/bin/ruby${RUBY_BUILD_VER} setup.rb --format-executable
cd ..
rm -rf rubygems-1.8.5
rm rubygems-1.8.5.tgz

DIR_PATH=`/bin/readlink -f "/usr/lib/ruby/gems/${RUBY_BUILD_VER}/bin"` # get rid of symlinks and get abs path
if test ! -d "${DIR_PATH}" || -n "${DIR_PATH}" ; then # now you're testing
    mkdir -p /usr/lib/ruby/gems/${RUBY_BUILD_VER}/bin
fi
RUBY_PRIORITY=`echo -n ${RUBY_VER}|sed -e 's/\.//g'`
update-alternatives \
  --install ${RUBY_ROOT} ruby ${RUBY_ROOT}${RUBY_BUILD_VER} ${RUBY_PRIORITY} \
  --slave   /usr/bin/ri   ri /usr/bin/ri${RUBY_BUILD_VER} \
  --slave   /usr/bin/erb  erb /usr/bin/erb${RUBY_BUILD_VER} \
  --slave   /usr/bin/rdoc rdoc /usr/bin/rdoc${RUBY_BUILD_VER} \
  --slave   /usr/bin/gem  gem /usr/bin/gem${RUBY_BUILD_VER} \
  --slave   /usr/bin/irb  irb /usr/bin/irb${RUBY_BUILD_VER} \
  --slave   /usr/bin/testrb  testrb /usr/bin/testrb${RUBY_BUILD_VER} \
  --slave   /usr/lib/ruby/gems/bin gem-bin /usr/lib/ruby/gems/${RUBY_BUILD_VER}/bin \
  --slave   /usr/share/man/man1/ruby.1 ruby.1 \
            /usr/share/man/man1/ruby${RUBY_BUILD_VER}.1 \

DIR_PATH=`readlink -f "/var/www"` # get rid of symlinks and get abs path
if test ! -d "${DIR_PATH}" ; then # now you're testing
    mkdir -p $DIR_PATH
fi
chown ${VEEWEE_USER}:${VEEWEE_USER} /var/www

### Install RVM
#
# Install 1.9.2-p180, under vagrant user account
# Set default RVM to the system Ruby 1.9.2 installed above.
cat <<'EOP' > /tmp/install_rvm.sh
#!/bin/bash
set -x
bash < <(curl -sk https://rvm.beginrescueend.com/install/rvm)
#-C --with-openssl-dir=$rvm_usr_dir,--with-libyaml-dir=$rvm_usr_dir,--with-readline-dir=$rvm_usr_dir
echo 'test -s "$HOME/.rvm/scripts/rvm" && source "$HOME/.rvm/scripts/rvm" # Load RVM function' >> $HOME/.bashrc
echo 'test -r $rvm_path/scripts/completion && source $rvm_path/scripts/completion # Load RVM bash completion' >> $HOME/.bashrc
echo 'test -s "$HOME/.rvm/scripts/rvm" && source "$HOME/.rvm/scripts/rvm" # Load RVM function' >> $HOME/.profile
echo 'test -r $rvm_path/scripts/completion && source $rvm_path/scripts/completion # Load RVM bash completion' >> $HOME/.profile
source "$HOME/.rvm/scripts/rvm"
type rvm | head -1
rvm install ruby-1.9.2-p180
cat <<'RVMRC_CONTENTS' > $HOME/.rvmrc
rvm_install_on_use_flag=1
rvm_trust_rvmrcs_flag=1
rvm_gemset_create_on_use_flag=1
RVMRC_CONTENTS
EOP

chmod a+x /tmp/install_rvm.sh
su --login - $VEEWEE_USER -c '/tmp/install_rvm.sh'

### Install Vagrant public key
#
DIR_PATH=`readlink -f "/home/${VEEWEE_USER}/.ssh"` # get rid of symlinks and get abs path
if test ! -d "${DIR_PATH}" ; then
    mkdir -p /home/${VEEWEE_USER}/.ssh
fi
chmod 700 /home/${VEEWEE_USER}/.ssh
cd /home/${VEEWEE_USER}/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chmod 0600  /home/${VEEWEE_USER}/.ssh/*
chown -R ${VEEWEE_USER} /home/${VEEWEE_USER}/.ssh
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.original
chmod a-w /etc/ssh/sshd_config.original
echo PubkeyAuthentication yes >>/etc/ssh/sshd_config
echo RSAAuthentication yes >>/etc/ssh/sshd_config
echo PasswordAuthentication no >>/etc/ssh/sshd_config
echo ChallengeResponseAuthentication no >>/etc/ssh/sshd_config
/etc/init.d/ssh restart

### Package Cleanup
#
# Remove items that aren't needed anymore
apt-get -y autoremove
apt-get clean


### Improve VM disk compression
#
# Zero out the free space to save space in the final image:
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

### Network fixes
#
# Removing leftover leases and persistent rules
echo "cleaning up dhcp leases"
rm /var/lib/dhcp3/*

# Make sure Udev doesn't block our network
# http://6.ptmc.org/?p=164
echo "cleaning up udev rules"
DIR_PATH=`readlink -f "/etc/udev/rules.d/70-persistent-net.rules"` # get rid of symlinks and get abs path
rm -rf /etc/udev/rules.d/70-persistent-net.rules
if test ! -d "${DIR_PATH}" ; then
    mkdir -p /etc/udev/rules.d/70-persistent-net.rules
fi
rm -rf /dev/.udev/
rm -rf /lib/udev/rules.d/75-persistent-net-generator.rules

echo "Adding a 2 sec delay to the interface up, to make the dhclient happy"
echo "pre-up sleep 2" >> /etc/network/interfaces

### Exit
#
exit 0
