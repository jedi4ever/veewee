# Install Puppet

source ./proxy.sh

cd /tmp
wget http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
rpm -ivh puppetlabs-release-el-6.noarch.rpm
rm -f /tmp/puppetlabs-release-el-6.noarch.rpm

yum -y install puppet facter
