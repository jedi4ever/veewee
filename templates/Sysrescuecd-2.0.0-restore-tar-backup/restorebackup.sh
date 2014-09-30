#! /bin/sh -x

# DONE REMOTELY FORM HOST SSH
#cat lxc-rootfs-template.tbz | ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p 7222 -l root 127.0.0.1 "cd /mnt/rootfs; tar xjf - --strip-components 1"

# DONE LOCALLY FROM GUEST

OUTPUTFILE=/tmp/backuptemp.tbz
BACKUPLOCATION=URL_GOES_HERE
wget $BACKUPLOCATION -O $OUTPUTFILE
cd /mnt/rootfs

# Blatent assumption is a tbz file
tar xjf $OUTPUTFILE --strip-components 1
#rm $OUTPUTFILE
ls -la /mnt/rootfs
