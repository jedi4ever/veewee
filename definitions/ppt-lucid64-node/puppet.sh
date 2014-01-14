# Install puppet from gem
wget -P /tmp/ http://apt.puppetlabs.com/puppetlabs-release-lucid.deb
dpkg -i /tmp/puppetlabs-release-lucid.deb
apt-get update
apt-get -y install puppet
