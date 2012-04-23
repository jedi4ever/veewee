cd /tmp
wget -q http://pyyaml.org/download/libyaml/yaml-0.1.4.tar.gz
tar xzf yaml-0.1.4.tar.gz
cd yaml-0.1.4
./configure --quiet --prefix=/usr/local
make --quiet
make install
cd ..
rm -rf yaml-0.1.4*

cd /tmp
wget -q http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p290.tar.gz
tar xzf ruby-1.9.2-p290.tar.gz
cd ruby-1.9.2-p290
./configure --quiet --prefix=/opt/ruby
make --quiet
make install
cd ..
rm -rf ruby-1.9.2-p290*

cd /tmp
wget http://production.cf.rubygems.org/rubygems/rubygems-1.8.6.tgz
tar xzf rubygems-1.8.6.tgz
cd rubygems-1.8.6
/opt/ruby/bin/ruby setup.rb
cd ..
rm -rf rubygems-1.8.6*

# Add /opt/ruby/bin to the global path as the last resort so
# Ruby and RubyGems
echo 'PATH=$PATH:/opt/ruby/bin/'> /etc/profile.d/vagrantruby.sh