# Install Puppet

source ./proxy.sh

cd /tmp

# Missing libselinux-ruby package in OL7 base repo
wget http://mirror.centos.org/centos-7/7.0.1406/os/x86_64/Packages/libselinux-ruby-2.2.2-6.el7.x86_64.rpm
rpm -Uvh libselinux-ruby-2.2.2-6.el7.x86_64.rpm
rm -f /tmp/libselinux-ruby-2.2.2-6.el7.x86_64.rpm

# Enable the Puppet Labs Package Repository
wget http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
rpm -Uvh puppetlabs-release-el-7.noarch.rpm
rm -f /tmp/puppetlabs-release-el-7.noarch.rpm

yum -y install puppet
