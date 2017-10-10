#!/bin/ash

# Requires
#    settings.sh
#    base.sh
#    sudo.sh
#    user.sh
#    apk.sh
#    virtualbox.sh

source /etc/profile

chroot $chroot /bin/ash <<DATAEOF

adduser -h /home/vagrant -G wheel -S -s /bin/ash vagrant
addgroup vagrant
adduser vagrant vagrant
adduser vagrant vboxsf

passwd -d vagrant
passwd vagrant<<EOF
vagrant
vagrant
EOF

mkdir -m 700 /home/vagrant/.ssh

# alpine has no shutdown, provide one for vagrant halt

cat <<EOF>/usr/local/bin/shutdown
#!/bin/sh
echo "This is just a call to poweroff..."
poweroff
EOF

chmod +x /usr/local/bin/shutdown

# add bash, because vagrant ssh checks the shell
apk add curl bash

curl -L 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' \
  -o /home/vagrant/.ssh/authorized_keys

chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

apk add nfs-utils
rc-update add rpc.statd default

DATAEOF
