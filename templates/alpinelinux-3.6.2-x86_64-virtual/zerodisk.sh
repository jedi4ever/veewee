#!/bin/ash

# Requires
#    settings.sh
#    base.sh
#    sudo.sh
#    user.sh
#    apk.sh
#    virtualbox.sh
#    vagrant.sh
#    ruby.sh
#    puppet.sh
#    chef.sh
#    cleanup.sh

source /etc/profile

chroot $chroot /bin/ash <<DATAEOF

# Zero out the free space to save space in the final image
dd if=/dev/zero of=/tmp/clean bs=1M
rm -f /tmp/clean
DATAEOF
