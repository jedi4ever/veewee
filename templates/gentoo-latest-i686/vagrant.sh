#!/bin/bash
source /etc/profile

# add default users and groups, setpasswords, configure privileges and install sudo
# PREREQUISITE: virtualbox guest additions - need the vboxguest group to exist
mkdir -p "$chroot/home/vagrant/.ssh"
chmod 700 "$chroot/home/vagrant/.ssh"
wget --no-check-certificate "$vagrant_ssh_key_url" -O "$chroot/home/vagrant/.ssh/authorized_keys"
chmod 600 "$chroot/home/vagrant/.ssh/authorized_keys"
cp -f /root/.vbox_version "$chroot/home/vagrant/.vbox_version"

# for passwordless logins
mkdir -p "$chroot/root/.ssh" 2> /dev/null
cat /tmp/ssh-root.pub >> "$chroot/root/.ssh/authorized_keys"

# add vagrant user
chroot $chroot /bin/bash <<DATAEOF
groupadd -r vagrant
useradd -m -r vagrant -g vagrant -G wheel,vboxsf,vboxguest -c 'added by vagrant, veewee basebox creation'

# set passwords (for after reboot)
passwd<<EOF
$password_root
$password_root
EOF

passwd vagrant<<EOF
$password_vagrant
$password_vagrant
EOF

# to each its own... home
chown -R vagrant /home/vagrant

emerge app-admin/sudo

echo 'sshd:ALL' > /etc/hosts.allow
echo 'ALL:ALL' > /etc/hosts.deny
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
DATAEOF

# configure ssh daemon
# veewee validate uses password authentication, so we have to enable it
cat <<DATAEOF > "$chroot/etc/ssh/sshd_config"
HostBasedAuthentication no
IgnoreUserKnownHosts yes
PasswordAuthentication yes
PermitRootLogin yes
PermitUserEnvironment no
PrintLastLog no
PrintMotd no
PubKeyAuthentication yes
Subsystem sftp internal-sftp
UseDNS no
UsePAM yes
UsePrivilegeSeparation sandbox
DATAEOF