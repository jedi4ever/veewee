#!/bin/bash
# based on http://www.funtoo.org/wiki/Funtoo_Linux_Installation

### SETTINGS ###

# user passwords for password based ssh logins
password_root=vagrant
password_vagrant=vagrant

# the public key for vagrants ssh
vagrant_ssh_key_url="https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub"

# these two (configuring the compiler) and the stage3 url can be changed to build a 32 bit system
accept_keywords="amd64"
chost="x86_64-pc-linux-gnu"

# stage 3 filename and full url
stage3file="stage3-latest.tar.xz"
stage3url="http://ftp.heanet.ie/mirrors/funtoo/funtoo-current/x86-64bit/generic_64/$stage3file"

# timezone (as subdirectory of /usr/share/zoneinfo)
timezone="UTC"

# and some static versions for programs
ruby_version="1.9.3-p194"
# rbenv and its plugins
rbenv_version="v0.3.0"
ruby_builder_version="v20120815"
rbenv_bundler_version="0.94"


### PARTITIONING ###

# for sgdisk (scripted gdisk) see: http://www.rodsbooks.com/gdisk/sgdisk.html
sgdisk -n 1:0:+128M -t 1:8300 -c 1:"linux-boot" \
       -n 2:0:+32M  -t 2:ef02 -c 2:"bios-boot"  \
       -n 3:0:+1G   -t 3:8200 -c 3:"swap"       \
       -n 4:0:0     -t 4:8300 -c 4:"linux-root" \
       -p /dev/sda

sleep 1

# format partitions, mount swap
mkswap /dev/sda3
swapon /dev/sda3
mkfs.ext2 /dev/sda1
mkfs.ext4 /dev/sda4

# this is our chroot directory for the installation
chroot=/mnt/gentoo

# mount other partitions
mount /dev/sda4 "$chroot" && cd "$chroot" && mkdir boot && mount /dev/sda1 boot


### BASE-INSTALLATION ###

# load stage 3, unpack it, delete the stage3 archive file
wget -nv --tries=5 "$stage3url"
tar xpf "$stage3file" && rm "$stage3file"

# prepeare chroot, update env
mount --bind /proc "$chroot/proc"
mount --bind /dev "$chroot/dev"


### INITIAL CONFIGURATION ###

# copy nameserver information, save build timestamp 
cp /etc/resolv.conf "$chroot/etc/"
date -u > "$chroot/etc/vagrant_box_build_time"
chroot "$chroot" env-update

#" activate client side dhcp and ssh by default
chroot "$chroot" /bin/bash <<DATAEOF
rc-update add dhcpcd default
rc-update add sshd default
DATAEOF

# set fstab
cat <<DATAEOF > "$chroot/etc/fstab"
# <fs>                  <mountpoint>    <type>          <opts>                   <dump/pass>
/dev/sda1               /boot           ext2            noauto,noatime           1 2
/dev/sda3               none            swap            sw                       0 0
/dev/sda4               /               ext4            noatime                  0 1
none                    /dev/shm        tmpfs           nodev,nosuid,noexec      0 0
DATAEOF

# make options
cat <<DATAEOF >> "$chroot/etc/portage/make.conf"
ACCEPT_KEYWORDS="$accept_keywords"
CHOST="$chost"
MAKEOPTS="-j$(($(</proc/cpuinfo grep processor|wc -l) + 1))"
LINGUAS=""
DATAEOF

# add package use flags
cat <<DATAEOF >> "$chroot/etc/portage/package.use"
sys-kernel/gentoo-sources symlink
sys-kernel/genkernel -cryptsetup
DATAEOF

# add package keywords
cat <<DATAEOF >> "$chroot/etc/portage/package.keywords"
app-emulation/virtualbox-guest-additions
DATAEOF

# update portage tree
chroot "$chroot" emerge --sync

# set localtime
chroot "$chroot" ln -sf "/usr/share/zoneinfo/$timezone" /etc/localtime

# get and install the kernel
chroot "$chroot" /bin/bash <<DATAEOF
emerge sys-kernel/gentoo-sources sys-kernel/genkernel sys-boot/boot-update
genkernel --install --symlink all
DATAEOF

# add default users and groups, setpasswords, configure privileges and install sudo
mkdir -p "$chroot/home/vagrant/.ssh"
chmod 700 "$chroot/home/vagrant/.ssh"
wget --no-check-certificate "$vagrant_ssh_key_url" -O "$chroot/home/vagrant/.ssh/authorized_keys"
chmod 600 "$chroot/home/vagrant/.ssh/authorized_keys"
cp -f /root/.vbox_version "$chroot/home/vagrant/.vbox_version"

chroot $chroot /bin/bash <<DATAEOF
groupadd -r vagrant
groupadd rbenv
useradd -m -r vagrant -g vagrant -G wheel,rbenv -c 'added by vagrant, veewee basebox creation'

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
#PermitRootLogin without-password
PermitUserEnvironment no
PrintLastLog no
PrintMotd no
PubKeyAuthentication yes
Subsystem sftp internal-sftp
UseDNS no
UsePAM yes
UsePrivilegeSeparation sandbox
DATAEOF

# install rbenv, ruby and bundler. Configure rbenv for global usage
# so it's usable without home directory
chroot "$chroot" /bin/bash <<DATAEOF
cd /usr/local/lib
git clone git://github.com/sstephenson/rbenv.git
cd rbenv
git checkout -b "$rbenv_version" "$rbenv_version"
mkdir -p env/plugins
cd env/plugins
git clone git://github.com/sstephenson/ruby-build.git
cd ruby-build
git checkout -b "$ruby_builder_version" "$ruby_builder_version"
cd ..
git clone git://github.com/carsomyr/rbenv-bundler.git
cd rbenv-bundler
git checkout -b "$rbenv_bundler_version" "$rbenv_bundler_version"
chgrp -R rbenv /usr/local/lib/rbenv
DATAEOF
libtool --finish /usr/lib64

# add rbenv to profile
cat <<DATAEOF >> "$chroot/etc/profile.d/rbenv.sh"
# add rbenv support
rbenv_base=/usr/local/lib/rbenv
export PATH=\$PATH:\$rbenv_base/bin
[ -n \$RBENV_ROOT ] && export RBENV_ROOT=\$rbenv_base/env
eval "\$(rbenv init -)"
DATAEOF

# install ruby, bundler, chef and puppet
chroot "$chroot" /bin/bash <<DATAEOF
env-update && source /etc/profile

# install ruby, use it as global version
emerge dev-libs/libyaml
rbenv install "$ruby_version"
rbenv global "$ruby_version"

# disable rdoc and ri
mkdir -p "/usr/local/lib/rbenv/env/versions/$ruby_version/etc"
cat <<EOF > "/usr/local/lib/rbenv/env/versions/$ruby_version/etc/gemrc"
# disable rdoc and ri
install: --no-rdoc --no-ri
update:  --no-rdoc --no-ri
EOF

# install required and desired gems
gem install bundler chef puppet
DATAEOF

# install the virtualbox guest additions
chroot "$chroot" /bin/bash <<DATAEOF
emerge app-admin/rsyslog sys-process/vixie-cron app-emulation/virtualbox-guest-additions
rc-update add rsyslog default
rc-update add vixie-cron default
rc-update add virtualbox-guest-additions default
DATAEOF

# configure boot entries
cat <<DATAEOF > "$chroot/etc/boot.conf"
boot {
  generate grub
  default "Funtoo Linux genkernel"
  timeout 3 
}

"Funtoo Linux genkernel" {
  kernel kernel[-v]
  initrd initramfs[-v]
  params += real_root=auto
} 
DATAEOF

# make the disk bootable
chroot "$chroot" /bin/bash <<DATAEOF
source /etc/profile && \
env-update && \
grub-install --no-floppy /dev/sda && \
boot-update
DATAEOF


### CLEANUP TO SHRINK THE BOX ###

# cleanup time...
chroot "$chroot" /bin/bash <<DATAEOF
# == potential savings : squashfs for portage and linux sources (~1.2 GB) ==
# emerge sys-fs/squashfs-tools
# * then, after directory cleanup:
#   squash /usr/src/linux-*
#   squash /usr/portage
#   fix fstab:
#    - mount squashed linux and portage
#    - mount secured temp folder with group "portage" to portage/distfiles

# delete temp, cached and build artifact data - some low hanging fruit...
cd /usr/src/linux
make mrproper
rm /tmp/*
rm -rf /var/log/*
rm -rf /var/tmp/*

# there's some leftover junk by gem installation in the root folder
# don't know where this is from (/root/.gem/specs/rubygems.org%80/...), but it should go...
# we use a global ruby by default
# ...probably hard coded path by mistake, report to upstream? Which upstream?!?
rm -rf /root/.gem

# we can safe quite some space on portage - but then we'd have to redownload it for installations.
# instead, we're pruning it (it still has to be recreated to update the package tree)
rm -rf /usr/portage/.git
rm -rf /usr/portage/distfiles/*

# get rid of the history for our git based installations
# - we could also load the tarball in the first place, comment this out if you want to be able to update rbenv...
rm -rf /usr/local/lib/rbenv/.git
rm -rf /usr/local/lib/rbenv/env/plugins/*/.git
DATAEOF

# fill all free hdd space with zeros
dd if=/dev/zero of="$chroot/boot/EMPTY" bs=1M
rm "$chroot/boot/EMPTY"

dd if=/dev/zero of="$chroot/EMPTY" bs=1M
rm "$chroot/EMPTY"

# fill all swap space with zeros and recreate swap
swapoff /dev/sda3
shred -n 0 -z /dev/sda3
mkswap /dev/sda3

exit