#!/bin/bash
source /etc/profile

chroot "$chroot" /bin/bash <<DATAEOF
 env-update && source /etc/profile
 emerge libyaml
 wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-$ruby_version.tar.gz
 tar xzf ruby-$ruby_version.tar.gz
 cd ruby-$ruby_version
 ./configure
 make
 make install
 cd ..
 rm -rf ruby-$ruby_version*
DATAEOF
