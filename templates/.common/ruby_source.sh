#!/bin/bash

source /etc/profile

wget -O- http://pyyaml.org/download/libyaml/yaml-$libyaml_version.tar.gz | tar oxz
cd yaml*
./configure --prefix=/usr/local
make && make install
cd ..
rm -rf *yaml*

wget -O- http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-$ruby_version.tar.gz | tar oxz
cd ruby*
./configure --prefix=/usr/local --enable-shared --disable-install-doc --with-opt-dir=/usr/local/lib
make && make install
cd ..
rm -rf *ruby-*

echo 'PATH=$PATH:/usr/local/bin' > /etc/profile.d/ruby.sh
