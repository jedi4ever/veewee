# Install Ruby

. ./proxy.sh

VERSION=1.9.3
RELEASE=p448

yum install -y readline-devel ncurses-devel gdbm-devel tcl-devel openssl-devel db4-devel byacc libyaml-devel libffi-devel make

wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-${VERSION}-${RELEASE}.tar.gz
tar zxf ruby-${VERSION}-${RELEASE}.tar.gz
cd ruby-${VERSION}-${RELEASE}
./configure
make && make install
cd ..
rm -rf ruby-${VERSION}-${RELEASE}
