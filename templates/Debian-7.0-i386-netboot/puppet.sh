# Prepare puppetlabs repo
wget http://apt.puppetlabs.com/puppetlabs-release-wheezy.deb
dpkg -i puppetlabs-release-wheezy.deb
apt-get update

# Install puppet/facter
apt-get install -y puppet facter
