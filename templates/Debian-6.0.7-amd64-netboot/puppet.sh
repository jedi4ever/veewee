# Prepare puppetlabs repo
wget http://apt.puppetlabs.com/puppetlabs-release-squeeze.deb
dpkg -i puppetlabs-release-squeeze.deb
apt-get update

# Install puppet/facter
apt-get install -y puppet facter
