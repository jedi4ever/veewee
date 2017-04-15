wget http://cache.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p353.tar.gz
tar xvzf ruby-2.0.0-p353.tar.gz
cd ruby-2.0.0-p353
./configure --prefix=/usr
make
make install
cd ..
rm -rf ruby-2.0.0-p353

