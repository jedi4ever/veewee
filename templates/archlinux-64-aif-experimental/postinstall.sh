#!/bin/bash

# launch automated install
#su -c 'aif -p automatic -c aif.cfg'

# chroot into the new system
mount -o bind /dev /mnt/dev
mount -o bind /sys /mnt/sys
mount -t proc none /mnt/proc
chroot /mnt

# make sure ssh is allowed
cat <<EOF > /etc/hosts.allow
sshd:	ALL
EOF

# make sure sshd starts
sed -i '$s/network /network sshd /' /etc/rc.conf

# set up user accounts
sed -i 's/root::/root:$1$9mqoT8YL$6pA27gnKGt0P1lQtlRDDb\/:/' /mnt/etc/shadow
echo 'vagrant:$1$9mqoT8YL$6pA27gnKGt0P1lQtlRDDb/:15167:0:99999:7:::' >> /mnt/etc/shadow
