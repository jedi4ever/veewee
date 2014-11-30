#!/bin/bash
source /etc/profile

# install Chef
chroot "$chroot" /bin/bash <<DATAEOF
gem install chef --no-rdoc --no-ri
DATAEOF
