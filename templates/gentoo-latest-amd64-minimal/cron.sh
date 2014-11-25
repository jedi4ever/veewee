#!/bin/bash
source /etc/profile

# install cron
chroot "$chroot" /bin/bash <<DATAEOF
emerge sys-process/vixie-cron
rc-update add vixie-cron default
DATAEOF
