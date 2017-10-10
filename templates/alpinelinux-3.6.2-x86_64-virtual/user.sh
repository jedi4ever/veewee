#!/bin/ash

# Requires
#   settings.sh
#   base.sh
#   sudo.sh

source /etc/profile

chroot $chroot /bin/ash <<DATAEOF

adduser -h /home/veewee -G wheel -S -s /bin/ash veewee
passwd -d veewee
passwd veewee<<EOF
veewee
veewee
EOF

DATAEOF
