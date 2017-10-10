#!/bin/ash

# Requires
#   
#   settings.sh
#   base.sh
#   sudo.sh
#   user.sh
#   apk.sh

source /etc/profile

chroot $chroot /bin/ash <<DATAEOF

apk add virtualbox-guest-modules-virthardened \
	virtualbox-guest-additions

cat <<EOF>> /etc/modules
vboxpci
vboxdrv
vboxnetflt
vboxsf
EOF

# For shared folders to work
addgroup vboxsf
addgroup veewee vboxsf

DATAEOF
