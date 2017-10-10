#!/bin/ash

# Requires
#    settings.sh
#    base.sh
#    sudo.sh
#    user.sh
#    apk.sh
#    virtualbox.sh

source /etc/profile

chroot $chroot /bin/ash <<DATAEOF
apk add ruby ruby-dev
DATAEOF
