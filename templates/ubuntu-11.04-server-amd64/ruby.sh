# Needed packages
apt-get -y install linux-headers-$(uname -r) build-essential
apt-get -y install zlib1g-dev libssl-dev libreadline5-dev
apt-get clean

# Install Ruby from source in /opt so that users of Vagrant
# can install their own Rubies using packages or however.
# We must install the 1.8.x series since Puppet doesn't support
# Ruby 1.9 yet.
wget http://ftp.ruby-lang.org/pub/ruby/1.8/ruby-1.8.7-p334.tar.gz
tar xvzf ruby-1.8.7-p334.tar.gz
cd ruby-1.8.7-p334
./configure --prefix=/opt/ruby
make
make install
cd ..
rm -rf ruby-1.8.7-p334*

# Install RubyGems 1.7.2
wget http://production.cf.rubygems.org/rubygems/rubygems-1.7.2.tgz
tar xzf rubygems-1.7.2.tgz
cd rubygems-1.7.2
/opt/ruby/bin/ruby setup.rb
cd ..
rm -rf rubygems-1.7.2*

# Add /opt/ruby/bin to the global path as the last resort so
# Ruby, RubyGems, and Chef/Puppet are visible
echo 'PATH=$PATH:/opt/ruby/bin/'> /etc/profile.d/vagrantruby.sh
