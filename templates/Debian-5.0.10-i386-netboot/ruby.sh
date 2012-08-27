#Installing ruby
apt-get -y install ruby ruby1.8-dev libopenssl-ruby1.8 rdoc ri irb make g++ libshadow-ruby1.8

# Install RubyGems 1.7.2
wget http://production.cf.rubygems.org/rubygems/rubygems-1.7.2.tgz
tar xzf rubygems-1.7.2.tgz
cd rubygems-1.7.2
/usr/bin/ruby setup.rb
cd ..
rm -rf rubygems-1.7.2*
ln -sfv /usr/bin/gem1.8 /usr/bin/gem
