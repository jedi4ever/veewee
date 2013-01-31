#!/bin/bash
# based on https://raw.github.com/jedi4ever/veewee/master/templates/funtoo-latest-x86_64/postinstall.sh

### SETTINGS ###

# user passwords for password based ssh logins
password_root=vagrant
password_vagrant=vagrant

# these two (configuring the compiler) and the stage3 url can be changed to build a 32 bit system
accept_keywords="amd64"
chost="x86_64-pc-linux-gnu"

# stage 3 filename and full url
stage3file="stage3-amd64-20130110.tar.bz2"
stage3url="http://distfiles.gentoo.org/releases/amd64/current-stage3/$stage3file"

# the public key for vagrants ssh
vagrant_ssh_key_url="https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub"

# timezone (as a subdirectory of /usr/share/zoneinfo)
timezone="UTC"

# locale
locale="en_US.utf8"

# number of cpus in the host system (to speed up make andfor kernel config)
nr_cpus=$(</proc/cpuinfo grep processor|wc -l)

### PARTITIONING AND FORMATTING ###

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

# bring up eth0 and sshd on boot
chroot "$chroot" /bin/bash <<DATAEOF
cd /etc/conf.d
echo 'config_eth0=( "dhcp" )' >> net
ln -s net.lo /etc/init.d/net.eth0
rc-update add net.eth0 default
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

# set make options
cat <<DATAEOF > "$chroot/etc/portage/make.conf"
CHOST="$chost"

CFLAGS="-mtune=generic -O2 -pipe"
CXXFLAGS="\${CFLAGS}"

ACCEPT_KEYWORDS="$accept_keywords"
MAKEOPTS="-j$((1 + $nr_cpus)) -l$nr_cpus.5"
EMERGE_DEFAULT_OPTS="-j$nr_cpus --quiet-build=y"
FEATURES="\${FEATURES} parallel-fetch"

# english only
LINGUAS=""

# for X support if needed
INPUT_DEVICES="evdev"
VIDEO_CARDS="virtualbox"

# use ruby 1.9
RUBY_TARGETS="ruby19"
DATAEOF

# add package use flags
cat <<DATAEOF >> "$chroot/etc/portage/package.use"
sys-kernel/gentoo-sources symlink
sys-kernel/genkernel -cryptsetup
DATAEOF

# add package keywords
cat <<DATAEOF >> "$chroot/etc/portage/package.keywords"
app-emulation/virtualbox-guest-additions ~amd64
dev-util/kbuild ~amd64
dev-util/ragel ~amd64
DATAEOF

# update portage tree to most current state
chroot "$chroot" emerge --sync

# set localtime
chroot "$chroot" ln -sf "/usr/share/zoneinfo/$timezone" /etc/localtime

# set locale
chroot "$chroot" /bin/bash <<DATAEOF
echo LANG=\"$locale\" > /etc/env.d/02locale
env-update && source /etc/profile
DATAEOF

# install grub
chroot "$chroot" emerge grub
chroot "$chroot" /bin/bash <<DATAEOF
cat <<GRUBCONF > /boot/grub/grub.conf
default 0
timeout 1

title=Gentoo Linux (3.6.11-gentoo)
root (hd0,0)
kernel /boot/kernel-genkernel-x86_64-3.6.11-gentoo root=/dev/ram0 real_root=/dev/sda4
initrd /boot/initramfs-genkernel-x86_64-3.6.11-gentoo
GRUBCONF
DATAEOF

# get, configure, compile and install the kernel and modules
chroot "$chroot" /bin/bash <<DATAEOF
emerge =sys-kernel/gentoo-sources-3.6.11 sys-kernel/genkernel gentoolkit

# specialize for VirtualBox - use loaded modules in livecd
cd /usr/src/linux
# use a default configuration as a starting point, then disable all currently unused modules
make defconfig
#make localyesconfig

# add settings for VirtualBox kernels to end of .config
cat <<EOF >>/usr/src/linux/.config
# dependencies
CONFIG_EXT4_FS=y
CONFIG_EXT4_USE_FOR_EXT23=y
CONFIG_EXT4_FS_XATTR=y
CONFIG_SMP=y
CONFIG_MODULE_UNLOAD=y
CONFIG_DMA_SHARED_BUFFER=y
# for VirtualBox
# see http://en.gentoo-wiki.com/wiki/Virtualbox_Guest
CONFIG_HIGH_RES_TIMERS=n
CONFIG_X86_MCE=n
CONFIG_SUSPEND=n
CONFIG_HIBERNATION=n
CONFIG_IDE=n
CONFIG_NO_HZ=y
CONFIG_SMP=y
CONFIG_ACPI=y
CONFIG_PNP=y
CONFIG_ATA=y
CONFIG_SATA_AHCI=y
CONFIG_ATA_SFF=y
CONFIG_ATA_PIIX=y
CONFIG_PCNET32=y
CONFIG_E1000=y
CONFIG_INPUT_MOUSE=y
CONFIG_DRM=y
CONFIG_SND_INTEL8X0=m
# for net fs
CONFIG_AUTOFS4_FS=m
CONFIG_NFS_V2=m
CONFIG_NFS_V3=m
CONFIG_NFS_V4=m
CONFIG_NFSD=m
CONFIG_CIFS=m
CONFIG_CIFS_UPCAL=y
CONFIG_CIFS_XATTR=y
CONFIG_CIFS_DFS_UPCALL=y
# reduce size
CONFIG_NR_CPUS=$nr_cpus
CONFIG_COMPAT_VDSO=n
# propbably nice but not in defaults
CONFIG_MODVERSIONS=y
CONFIG_IKCONFIG_PROC=y
CONFIG_SQUASHFS=y
CONFIG_SQUASHFS_XATTR=y
CONFIG_SQUASHFS_XZ=y
#CONFIG_EFI_STUB=y
#CONFIG_DEFAULT_DEADLINE=y
#CONFIG_DEFAULT_CFQ=n
#CONFIG_PREEMPT_NONE=y
#CONFIG_PREEMPT_VOLUNTARY=n
#CONFIG_HZ=100=y
#CONFIG_HZ=1000=n
# IPSec (I want to run tests with IPSec andSamba 4)
CONFIG_NET_IPVTI=y
CONFIG_INET_AH=y
CONFIG_INET_ESP=y
CONFIG_INET_IPCOMP=y
CONFIG_INET_XFRM_MODE_TRANSPORT=y
CONFIG_INET_XFRM_MODE_TUNNEL=y
CONFIG_INET_XFRM_MODE_BEET=y
CONFIG_INET6_AH=y
CONFIG_INET6_ESP=y
CONFIG_INET6_IPCOMP=y
CONFIG_INET6_XFRM_MODE_TRANSPORT=y
CONFIG_INET6_XFRM_MODE_TUNNEL=y
CONFIG_INET6_XFRM_MODE_BEET=y
# and some more crypto support...
CONFIG_CRYPTO_USER=m
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1_SSSE3=m
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=m
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_SALSA20_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
CONFIG_CRYPTO_DEFLATE=y
# rtc
CONFIG_RTC=y
EOF
# build and install kernel, using the config created above
genkernel --install --symlink --oldconfig --bootloader=grub all
DATAEOF

# install the virtualbox guest additions, add vagrant and root to group vboxguest
# PREREQUISITE: kernel - we install a module, so we use the kernel sources
chroot "$chroot" /bin/bash <<DATAEOF
emerge sys-apps/dbus app-emulation/virtualbox-guest-additions
# we need this as gentoo doesn't do it on its own
groupadd -r vboxsf
mkdir /media && chgrp vboxsf /media
rc-update add dbus default # required by virtualbox-guest-additions service
rc-update add virtualbox-guest-additions default
DATAEOF

# add default users and groups, setpasswords, configure privileges and install sudo
mkdir -p "$chroot/home/vagrant/.ssh"
chmod 700 "$chroot/home/vagrant/.ssh"
wget --no-check-certificate "$vagrant_ssh_key_url" -O "$chroot/home/vagrant/.ssh/authorized_keys"
chmod 600 "$chroot/home/vagrant/.ssh/authorized_keys"
cp -f /root/.vbox_version "$chroot/home/vagrant/.vbox_version"

# for passwordless logins
mkdir -p "$chroot/root/.ssh" 2> /dev/null
cat /tmp/ssh-root.pub >> "$chroot/root/.ssh/authorized_keys"

# PREREQUISITE: virtualbox-guest-additions - the groups created on installation have to exist
chroot $chroot /bin/bash <<DATAEOF
groupadd -r vagrant
groupadd -r rbenv
useradd -m -r vagrant -g vagrant -G wheel,rbenv,vboxsf,vboxguest -c 'added by vagrant, veewee basebox creation'

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
# veewee validate uses password authentication (according to the other Funtoo-template), so we have to enable it
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

# install ruby, bundler, chef and puppet
chroot "$chroot" /bin/bash <<DATAEOF
env-update && source /etc/profile
emerge --autounmask-write ruby:1.9
eselect ruby set ruby19

# install required and desired gems
gem install bundler chef puppet --no-rdoc --no-ri
DATAEOF

# install logger and cron
chroot "$chroot" /bin/bash <<DATAEOF
emerge app-admin/rsyslog sys-process/vixie-cron
rc-update add rsyslog default
rc-update add vixie-cron default
DATAEOF

# install nfs and automount support
chroot "$chroot" emerge net-fs/nfs-utils net-fs/autofs

# make the disk bootable
chroot "$chroot" /bin/bash <<DATAEOF
source /etc/profile && \
env-update && \
grep -v rootfs /proc/mounts > /etc/mtab && \
grub-install --no-floppy /dev/sda
DATAEOF

# fix a weird issue with sshd not starting
# http://www.linuxquestions.org/questions/linux-networking-3/sshd-fatal-daemon-failed-no-such-device-279664/
chroot "$chroot" /bin/bash <<DATAEOF
rm /dev/null
mknod /dev/null c 1 3
chmod 0666 /dev/null
DATAEOF

### CLEANUP TO SHRINK THE BOX ###

# a fresh install probably shouldn't nag about news
chroot "$chroot" /usr/bin/eselect news read all

# cleanup time...
chroot "$chroot" /bin/bash <<DATAEOF
# delete temp, cached and build artifact data
eclean -d distfiles
rm /tmp/*
rm -rf /var/log/*
rm -rf /var/tmp/*
rm -rf /root/.gem
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
