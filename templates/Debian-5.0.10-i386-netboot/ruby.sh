# Installing ruby from packages
apt-get -y install ruby ruby1.8-dev libopenssl-ruby1.8 rdoc ri irb make g++ libshadow-ruby1.8

# Install RubyGems 1.8.25
rg_ver=1.8.25
wget http://production.cf.rubygems.org/rubygems/rubygems-${rg_ver}.tgz
tar xzf rubygems-${rg_ver}.tgz
cd rubygems-${rg_ver}
/usr/bin/ruby setup.rb
cd ..
rm -rf rubygems-${rg_ver}*
ln -sfv /usr/bin/gem1.8 /usr/bin/gem
