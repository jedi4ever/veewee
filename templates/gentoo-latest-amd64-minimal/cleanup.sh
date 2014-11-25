#!/bin/bash
source /etc/profile

# fix a weird issue with sshd not starting
# http://www.linuxquestions.org/questions/linux-networking-3/sshd-fatal-daemon-failed-no-such-device-279664/
chroot "$chroot" /bin/bash <<DATAEOF
rm -f /dev/null
mknod /dev/null c 1 3
chmod 0666 /dev/null
DATAEOF

# skip all the news
chroot "$chroot" /usr/bin/eselect news read all

# cleanup
chroot "$chroot" /bin/bash <<DATAEOF
# delete temp, cached and build artifact data
eclean -d distfiles
rm /tmp/*
rm -rf /var/log/*
rm -rf /var/tmp/*
rm /etc/profile.d/settings.sh

# clean root
rm -rf /root/.gem
#rm -rf /root/*
DATAEOF
