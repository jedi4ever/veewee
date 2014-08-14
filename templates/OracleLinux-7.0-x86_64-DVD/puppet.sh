# Install Puppet

source ./proxy.sh

cd /tmp

# Missing libselinux-ruby package is available in ol7_optional_latest
# enabled in base.sh

# Enable the Puppet Labs Package Repository
wget http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
rpm -Uvh puppetlabs-release-el-7.noarch.rpm
rm -f /tmp/puppetlabs-release-el-7.noarch.rpm

yum -y install puppet
