# Install Puppet

set -x

if [ -e ./proxy.sh ] ; then
  source ./proxy.sh
fi

rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm

yum -y install puppet facter
