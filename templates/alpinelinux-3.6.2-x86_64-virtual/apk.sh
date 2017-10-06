#!/bin/ash

# Requires
#   
#   settings.sh
#   base.sh
#   sudo.sh
#   user.sh

source /etc/profile

chroot $chroot /bin/ash <<DATAEOF
sed -i '/v3.6\/community/s/^#//' /etc/apk/repositories
apk update
DATAEOF
