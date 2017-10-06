#!/bin/ash

# Requires
#   base.sh

source /etc/profile

chroot $chroot /bin/ash <<DATAEOF

apk add sudo

cat <<EOF > /etc/sudoers
root ALL=(ALL) ALL
%wheel ALL=(ALL) NOPASSWD: ALL
EOF

DATAEOF
