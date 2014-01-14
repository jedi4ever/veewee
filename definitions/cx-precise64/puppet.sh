# Install Puppet
wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
dpkg -i /tmp/puppetlabs-release-precise.deb
apt-get update
apt-get -y install puppet
