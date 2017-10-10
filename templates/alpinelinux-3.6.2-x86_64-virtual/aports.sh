#!/bin/ash

# Requires
#    settings.sh
#    base.sh
#    sudo.sh
#    user.sh
#    apk.sh
#    virtualbox.sh
#    vagrant.sh

source /etc/profile

chroot $chroot /bin/ash <<DATAEOF
apk add alpine-sdk
su - vagrant -c 'cd ~/ && git clone git://git.alpinelinux.org/aports'

addgroup vagrant abuild

mkdir -p /var/cache/distfiles
chmod a+w /var/cache/distfiles
chgrp abuild /var/cache/distfiles
chmod g+w /var/cache/distfiles

echo "Don't forget to run 'abuild-keygen -a -i'" >> /home/vagrant/README.ABUILD
chown vagrant:vagrant /home/vagrant/README.ABUILD
DATAEOF


