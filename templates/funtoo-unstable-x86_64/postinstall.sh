#!/bin/bash
# based on http://www.funtoo.org/wiki/Funtoo_Linux_Installation

### SETTINGS ###

# user passwords for password based ssh logins
password_root=vagrant
password_vagrant=vagrant

# static versions of programs we install
ruby_version="ruby:2.1" #"1.9.3-p286"
ruby_pretty="$(echo $ruby_version | tr -d [:.])"

# these two (configuring the compiler) and the stage3 url can be changed to build a 32 bit system
accept_keywords="~amd64"
chost="x86_64-pc-linux-gnu"

# stage 3 filename and full url
# http://ftp.osuosl.org/pub/funtoo/
# http://ftp.heanet.ie/mirrors/funtoo/
stage3file="stage3-latest.tar.xz"
stage3url="http://ftp.osuosl.org/pub/funtoo/funtoo-current/x86-64bit/generic_64/$stage3file"

# the public key for vagrants ssh
vagrant_ssh_key_url="https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub"

# timezone (as a subdirectory of /usr/share/zoneinfo)
timezone="UTC"

# number of cpus in the host system (to speed up make andfor kernel config)
nr_cpus=$(</proc/cpuinfo grep processor|wc -l)


### PARTITIONING AND FORMATTING ###

# for sgdisk (scripted gdisk) see: http://www.rodsbooks.com/gdisk/sgdisk.html
sgdisk -n 1:0:+128M -t 1:8300 -c 1:"linux-boot" \
       -n 2:0:+32M  -t 2:ef02 -c 2:"bios-boot"  \
       -n 3:0:+1G   -t 3:8200 -c 3:"swap"       \
       -n 4:0:0     -t 4:8300 -c 4:"linux-root" \
       -p /dev/sda

#sleep 1

# format partitions, mount swap
mkswap /dev/sda3
swapon /dev/sda3
mkfs.ext2 /dev/sda1
mkfs.ext4 /dev/sda4

# verify to be sure that partitions are okay
sgdisk -v /dev/sda
sgdisk -p /dev/sda

# this is our chroot directory for the installation
chroot_dir=/mnt/gentoo

# mount other partitions
mount /dev/sda4 "${chroot_dir}" && cd "${chroot_dir}" && mkdir boot && mount /dev/sda1 boot


### BASE-INSTALLATION ###

# load stage 3, unpack it, delete the stage3 archive file
wget -nv --tries=5 "$stage3url"
tar xpf "$stage3file" && rm "$stage3file"

# prepeare chroot, update env
mount --bind /proc "${chroot_dir}/proc"
mount --bind /dev "${chroot_dir}/dev"


### INITIAL CONFIGURATION ###

# copy nameserver information, save build timestamp
cp /etc/resolv.conf "${chroot_dir}/etc/"
date -u > "${chroot_dir}/etc/vagrant_box_build_time"
#chroot "${chroot_dir}" env-update

#" activate client side dhcp and ssh by default
chroot "${chroot_dir}" /bin/bash <<DATAEOF
rc-update add dhcpcd default
rc-update add sshd default
DATAEOF

# set fstab
cat <<DATAEOF > "${chroot_dir}/etc/fstab"
# <fs>                  <mountpoint>    <type>          <opts>                   <dump/pass>
/dev/sda1               /boot           ext2            noauto,noatime           1 2
/dev/sda3               none            swap            sw                       0 0
/dev/sda4               /               ext4            noatime                  0 1
none                    /dev/shm        tmpfs           nodev,nosuid,noexec      0 0
DATAEOF

# set make options
cat <<DATAEOF > "${chroot_dir}/etc/portage/make.conf"
CHOST="$chost"

CFLAGS="-mtune=generic -O2 -pipe"
CXXFLAGS="\${CFLAGS}"

ACCEPT_KEYWORDS="$accept_keywords"
MAKEOPTS="-j$((1 + $nr_cpus)) -l$nr_cpus.5"
EMERGE_DEFAULT_OPTS="-j$nr_cpus --quiet-build=y"
FEATURES="\${FEATURES} parallel-fetch"
GENTOO_MIRRORS="http://distfiles ${GENTOO_MIRRORS}"
# no reason to keep these hanging around
DISTDIR="/tmp/distfiles"
# english only
LINGUAS=""

# get us some ruby
RUBY_TARGETS="${ruby_pretty}"
USE="ruby"

# for X support if needed
INPUT_DEVICES="evdev"
VIDEO_CARDS="virtualbox"
DATAEOF

# add package use flags
cat <<DATAEOF >> "${chroot_dir}/etc/portage/package.use"
sys-kernel/gentoo-sources symlink
sys-kernel/genkernel -cryptsetup
DATAEOF

# add package keywords
cat <<DATAEOF >> "${chroot_dir}/etc/portage/package.keywords"
app-emulation/virtualbox-guest-additions
DATAEOF

# update portage tree to most current state git://github.com/funtoo/ports-2012.git
remote_git='git://github.com/funtoo/ports-2012.git' # 'git://home/ports-2012.git'
echo "cloning  to /usr/portage"
chroot "${chroot_dir}" git clone --depth 1 ${remote_git} /usr/portage
chroot "${chroot_dir}" emerge --sync
chroot "${chroot_dir}" env-update

# set localtime
chroot "${chroot_dir}" ln -sf "/usr/share/zoneinfo/$timezone" /etc/localtime

# get, configure, compile and install the kernel and modules
chroot "${chroot_dir}" /bin/bash <<DATAEOF
emerge sys-kernel/gentoo-sources sys-kernel/genkernel sys-boot/boot-update

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
EOF
# build and install kernel, using the config created above
genkernel --install --symlink --oldconfig all
DATAEOF

# install the virtualbox guest additions, add vagrant and root to group vboxguest
# PREREQUISITE: kernel - we install a module, so we use the kernel sources
chroot "${chroot_dir}" /bin/bash <<DATAEOF
emerge app-emulation/virtualbox-guest-additions
mkdir /media && chgrp vboxsf /media
rc-update add virtualbox-guest-additions default
DATAEOF

# for passwordless logins
mkdir -p "${chroot_dir}/root/.ssh" 2> /dev/null
cat /tmp/ssh-root.pub >> "${chroot_dir}/root/.ssh/authorized_keys"

# PREREQUISITE: virtualbox-guest-additions - the groups created on installation have to exist
chroot ${chroot_dir} /bin/bash <<DATAEOF
groupadd -r vagrant
useradd -m -r vagrant -g vagrant -G wheel,vboxsf,vboxguest -c 'added by vagrant, veewee basebox creation'
DATAEOF

# add default users and groups, setpasswords, configure privileges and install sudo
mkdir -p "${chroot_dir}/home/vagrant/.ssh"
chmod 700 "${chroot_dir}/home/vagrant/.ssh"
wget --no-check-certificate "$vagrant_ssh_key_url" -O "${chroot_dir}/home/vagrant/.ssh/authorized_keys"
chmod 600 "${chroot_dir}/home/vagrant/.ssh/authorized_keys"
cp -f /root/.vbox_version "${chroot_dir}/home/vagrant/.vbox_version"

# set passwords (for after reboot)
chroot ${chroot_dir} /bin/bash <<DATAEOF
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
cat <<DATAEOF > "${chroot_dir}/etc/ssh/sshd_config"
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
echo "Install ruby, bundler, chef and puppet"
chroot "${chroot_dir}" /bin/bash <<DATAEOF
env-update && source /etc/profile

# install ruby, use it as global version
emerge dev-libs/libyaml
emerge ${ruby_version}
# set this as our default ruby.  remove : and .
eselect ruby set ${ruby_pretty}


# disable rdoc and ri
cat <<EOF > "/etc/gemrc"
# disable rdoc and ri
install: --no-rdoc --no-ri
update:  --no-rdoc --no-ri
EOF

# install required and desired gems
gem install bundler chef puppet
DATAEOF

echo "Patch puppet if needed"
# ignore errors from this
chroot "${chroot_dir}" /bin/bash <<DATAOF
env-update && source /etc/profile

if puppet -V > /dev/null 2>&1
then
    echo "puppet works, not patching"
else
    echo "patching puppet"
    monkey_patch=\$(find \$(find /usr/local/lib64/ruby/gems  -name "puppet-*" -type d |head -1) -name monkey_patches.rb)
    if [ -f \${monkey_patch} ]
    then
        cd \$(dirname \${monkey_patch})
        patch <<EOF
--- monkey_patches.rb   2014-01-12 06:14:38.703623725 +0000
+++ monkey_patches_fix.rb       2014-01-12 06:17:16.555685910 +0000
@@ -67,19 +67,24 @@
 end

 class Symbol
-  # So, it turns out that one of the biggest memory allocation hot-spots in
-  # our code was using symbol-to-proc - because it allocated a new instance
-  # every time it was called, rather than caching.
+  # So, it turns out that one of the biggest memory allocation hot-spots in our
+  # code was using symbol-to-proc - because it allocated a new instance every
+  # time it was called, rather than caching (in Ruby 1.8.7 and earlier).
+  #
+  # In Ruby 1.9.3 and later Symbol#to_proc does implement a cache so we skip
+  # our monkey patch.
   #
   # Changing this means we can see XX memory reduction...
-  if method_defined? :to_proc
-    alias __original_to_proc to_proc
-    def to_proc
-      @my_proc ||= __original_to_proc
-    end
-  else
-    def to_proc
-      @my_proc ||= Proc.new {|*args| args.shift.__send__(self, *args) }
+  if RUBY_VERSION < "1.9.3"
+    if method_defined? :to_proc
+      alias __original_to_proc to_proc
+      def to_proc
+        @my_proc ||= __original_to_proc
+      end
+    else
+      def to_proc
+        @my_proc ||= Proc.new {|*args| args.shift.__send__(self, *args) }
+      end
     end
   end
EOF
    fi
fi

DATAOF

# install logger and cron
chroot "${chroot_dir}" /bin/bash <<DATAEOF
emerge app-admin/rsyslog sys-process/vixie-cron
rc-update add rsyslog default
rc-update add vixie-cron default
DATAEOF

# install nfs and automount support
# chroot "${chroot_dir}" emerge net-fs/nfs-utils net-fs/autofs

# make the disk bootable
chroot "${chroot_dir}" /bin/bash <<DATAEOF
source /etc/profile && \
env-update && \
grub-install --no-floppy /dev/sda && \
boot-update
# Patching the boot configuration as we have no initramfs
cd /boot/grub
mv grub.cfg grub.bkp
awk '{sub(/real_root/,"root")};1' grub.bkp > grub.cfg
cat grub.cfg
DATAEOF

### patch to make lib/vagrant/guest/gentoo.rb happy
# not needed for much longer
chroot "${chroot_dir}" /bin/bash <<DATAEOF
cd /etc/init.d
ln -s net.lo netif.lo
DATAEOF


### CLEANUP TO SHRINK THE BOX ###

# a fresh install probably shouldn't nag about news
chroot "${chroot_dir}" /usr/bin/eselect news read all > /dev/null 2>&1

# cleanup time...
chroot "${chroot_dir}" /bin/bash <<DATAEOF
# delete temp, cached and build artifact data - some low hanging fruit...

#this is kinda big...  
rm -r /usr/src/linux/drivers

eclean -d distfiles
rm -rf /tmp/*
rm -rf /var/log/*
rm -rf /var/tmp/*

# there's some leftover junk by gem installation in the root folder
# don't know where this is from (/root/.gem/specs/rubygems.org%80/...), but it should go...
# we use a global ruby by default
# ...probably hard coded path by mistake, report to upstream? Which upstream?!?
rm -rf /root/.gem

# here's some savings crippling the usage of this box (sorted descending by damage)
#rm -rf /usr/src/linux*
DATAEOF

# fill all free hdd space with zeros
dd if=/dev/zero of="${chroot_dir}/boot/EMPTY" bs=1M
rm "${chroot_dir}/boot/EMPTY"

dd if=/dev/zero of="${chroot_dir}/EMPTY" bs=1M
rm "${chroot_dir}/EMPTY"

# fill all swap space with zeros and recreate swap
swapoff /dev/sda3
shred -n 0 -z /dev/sda3
mkswap /dev/sda3

exit
