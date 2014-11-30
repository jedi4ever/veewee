#!/bin/bash
source /etc/profile

# install Puppet
chroot "$chroot" /bin/bash <<DATAEOF
gem install puppet --no-rdoc --no-ri
DATAEOF
