# Install Ruby from source

source ./proxy.sh

RUBY_VERSION="ruby-1.9.3-p547"
RUBY_SOURCE="http://ftp.ruby-lang.org/pub/ruby/1.9/${RUBY_VERSION}.tar.gz"
LIBYAML_VERSION="yaml-0.1.5"
LIBYAML_SOURCE="http://pyyaml.org/download/libyaml/${LIBYAML_VERSION}.tar.gz"

yum install -y readline-devel ncurses-devel gdbm-devel tcl-devel \
  openssl-devel db4-devel byacc libyaml-devel libffi-devel make

# Install libyaml from source
cd /tmp
wget $LIBYAML_SOURCE
tar zxf ${LIBYAML_VERSION}.tar.gz
cd $LIBYAML_VERSION
./configure
make && make install

cd /tmp
wget $RUBY_SOURCE
tar zxf ${RUBY_VERSION}.tar.gz
cd $RUBY_VERSION
./configure
make && make install
cd /tmp
rm -rf $RUBY_VERSION
rm /tmp/${RUBY_VERSION}.tar.gz
ln -s /usr/local/bin/ruby /usr/bin/ruby # Create a sym link for the same path
ln -s /usr/local/bin/gem /usr/bin/gem # Create a sym link for the same path

# Needed if Ruby is compiled from source
cat > /etc/profile.d/local.sh<<'EOF'
export PATH=$PATH:/usr/local/sbin:/usr/local/bin
EOF
