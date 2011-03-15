#First install sudo
cd /usr/ports/security/sudo
make install -DBATCH

#We prefer bash to be there
cd /usr/ports/shells/bash
make install -DBATCH

#Off to rubygems to get first ruby running
cd /usr/ports/dev/ruby-gems
make install -DBATCH

#Gem chef
cd /usr/ports/sysutils/rubygem-chef
make install -DBATCH

#Now only if we could get things to install in /usr instead of /usr/local

#Gem puppet

#Virtualbox additions