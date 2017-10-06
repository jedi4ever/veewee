#!/bin/ash

# settings that will be shared between all scripts
cat <<DATAEOF > "/etc/profile.d/veewee.sh"
export chroot=/mnt
DATAEOF
