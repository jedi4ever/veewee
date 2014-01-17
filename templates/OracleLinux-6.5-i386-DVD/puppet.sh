# Install Puppet

source ./proxy.sh

cd /tmp
wget https://yum.puppetlabs.com/el/6/products/i386/puppetlabs-release-6-7.noarch.rpm
rpm -ivh puppetlabs-release-6-7.noarch.rpm
rm -f /tmp/puppetlabs-release-6-7.noarch.rpm

yum -y install puppet facter
