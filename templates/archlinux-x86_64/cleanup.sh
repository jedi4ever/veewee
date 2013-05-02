#!/bin/bash

# Requires
#   reboot.sh

# Clean up
# http://vstone.eu/reducing-vagrant-box-size/
unset HISTFILE
[ -f /root/.bash_history ] && rm /root/.bash_history

# Clean up logfiles
find /var/log -type f | while read f; do echo -ne '' > $f; done;

# Clean out Pacman cache
pacman -Scc<<EOF
y
y
EOF

# Clean out the SystemD service that may have been created for the reboot
rm -f /etc/systemd/system/systemd-user-sessions.service
