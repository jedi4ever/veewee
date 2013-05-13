#!/bin/bash

#remove temp files
rm /root/kernel_version

# fix a weird issue with sshd not starting
# http://www.linuxquestions.org/questions/linux-networking-3/sshd-fatal-daemon-failed-no-such-device-279664/
rm -f /dev/null
mknod /dev/null c 1 3
chmod 0666 /dev/null

# skip all the news
/usr/bin/eselect news read all

# cleanup
# delete temp, cached and build artifact data
eclean -d distfiles
rm /tmp/*
rm -rf /var/log/*
rm -rf /var/tmp/*
rm -rf /root/.gem

# clean profile data
rm -rf /etc/profile.d/*
