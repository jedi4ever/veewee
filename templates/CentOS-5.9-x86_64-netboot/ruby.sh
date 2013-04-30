# Installing ruby
cd /tmp
wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p180.tar.gz || fail "Could not download Ruby source"
tar xzvf ruby-1.9.2-p180.tar.gz
cd ruby-1.9.2-p180
./configure
make && make install
cd /tmp
rm -rf /tmp/ruby-1.9.2-p180
rm /tmp/ruby-1.9.2-p180.tar.gz
ln -s /usr/local/bin/ruby /usr/bin/ruby # Create a sym link for the same path
ln -s /usr/local/bin/gem /usr/bin/gem # Create a sym link for the same path
