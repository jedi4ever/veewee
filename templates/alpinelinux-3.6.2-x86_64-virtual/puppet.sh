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
 
source /etc/profile

chroot $chroot /bin/ash <<DATAEOF
apk add ruby-irb ruby-json
gem install puppet --no-document
DATAEOF


