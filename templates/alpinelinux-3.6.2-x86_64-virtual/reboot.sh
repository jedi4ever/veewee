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
#    zerodisk.sh

source /etc/profile

chroot $chroot /bin/ash <<"DATAEOF"
# Delete all veewee related files that were copied over, including this script
rm -rf /root/{*,.v*}
DATAEOF

# reboot, mainly to enable grsec again
umount /mnt/boot
umount -lf /mnt
reboot
