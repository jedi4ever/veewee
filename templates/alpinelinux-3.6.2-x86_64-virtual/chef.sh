#!/bin/ash

# Requires
#    settings.sh
#    base.sh
#    sudo.sh
#    user.sh
#    apk.sh
#    virtualbox.sh
#    ruby.sh
#    vagrant.sh
#    puppet.sh
 
source /etc/profile

chroot $chroot /bin/ash <<DATAEOF
apk add yajl-dev build-base libffi-dev ruby-io-console
gem install chef --no-document
DATAEOF


