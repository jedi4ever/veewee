#!/bin/bash
source /etc/profile

# install system logger
chroot "$chroot" /bin/bash <<DATAEOF
emerge app-admin/rsyslog
rc-update add rsyslog default
DATAEOF
