cd /tmp

wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p392.tar.gz
tar xvzf ruby-1.9.3-p392.tar.gz
cd ruby-1.9.3-p392
./configure --prefix=/opt/ruby
make
make install
cd ..
rm -rf ruby-1.9.3-p392
rm ruby-1.9.3-p392.tar.gz

wget http://production.cf.rubygems.org/rubygems/rubygems-2.0.3.tgz
tar xzf rubygems-2.0.3.tgz
cd rubygems-2.0.3
/opt/ruby/bin/ruby setup.rb
