#!/bin/bash
source /etc/profile

# add default users and groups, setpasswords, configure privileges and install sudo
# PREREQUISITE: virtualbox guest additions - need the vboxguest group to exist
mkdir -p "$chroot/home/vagrant/.ssh"
chmod 700 "$chroot/home/vagrant/.ssh"
wget --no-check-certificate "$vagrant_ssh_key_url" -O "$chroot/home/vagrant/.ssh/authorized_keys"
chmod 600 "$chroot/home/vagrant/.ssh/authorized_keys"

# record virtualbox version
cp -f /root/.vbox_version "$chroot/home/vagrant/.vbox_version"
vbox_version=$(cat /root/.vbox_version)
echo "export vbox_version=$vbox_version" >> /etc/profile.d/settings.sh
cp /etc/profile.d/settings.sh $CHROOT/etc/profile.d/

mkdir -p "$chroot/root/.ssh" 2> /dev/null

# add vagrant user
chroot $chroot /bin/bash <<DATAEOF
groupadd -r vagrant
useradd -m -r vagrant -g vagrant -G wheel,vboxsf,vboxguest,video -c 'Vagrant user'

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
Protocol 2
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

# X11 features need openssh emerged with USE flag "X"
X11Forwarding yes
X11DisplayOffset 10
X11UseLocalhost yes
DATAEOF


# Set locale (glibc)

# generate locale
chroot "$chroot" /bin/bash <<DATAEOF
echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
#echo ja_JP.UTF-8 UTF-8 >> /etc/locale.gen
#echo fa_IR UTF-8 >> /etc/locale.gen
locale-gen
DATAEOF

# set locale
chroot "$chroot" /bin/bash <<DATAEOF
echo LC_ALL=\"$locale\" >> /etc/env.d/02locale
echo LC_TYPE=\"$locale\" >> /etc/env.d/02locale
env-update && source /etc/profile
DATAEOF

# make hostname shorter 
cat <<DATAEOF > "$chroot/etc/conf.d/hostname"
# Set to the hostname of this machine
hostname="local"
DATAEOF

