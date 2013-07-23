# Install Puppet

. ./proxy.sh

if [ -e "/usr/local/bin/gem" ] ; then
  /usr/local/bin/gem install --no-ri --no-rdoc puppet
else
  gem install --no-ri --no-rdoc puppet
fi