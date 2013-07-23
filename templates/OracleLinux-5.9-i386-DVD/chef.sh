. ./proxy.sh

# Install Chef
if [ -e "/usr/local/bin/gem" ] ; then
  /usr/local/bin/gem install --no-ri --no-rdoc chef
else
  gem install --no-ri --no-rdoc chef
fi