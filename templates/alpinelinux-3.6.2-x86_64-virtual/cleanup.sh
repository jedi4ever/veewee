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

source /etc/profile

chroot $chroot /bin/ash <<"DATAEOF"
# Clean up
unset HISTFILE
[ -f /root/.bash_history ] && rm /root/.bash_history

# Clean up logfiles
find /var/log -type f | while read f; do echo -ne '' > $f; done

DATAEOF
