date > /etc/vagrant_box_build_time

#http://www.freebsd.org/doc/en_US.ISO8859-1/articles/remote-install/installation.html
dd if=/dev/zero of=/dev/ad4 count=2
#bsdlabel -w -B /dev/ad4

sysctl kern.geom.debugflags=16

#http://forum.nginx.org/read.php?23,146311,146451
# Init the disk with an MBR
gpart create -s mbr ad4
# Create a BSD container
gpart add -t freebsd ad4
# Init with a BSD scheme
gpart create -s bsd ad4s1

# 1GB for /
gpart add -t freebsd-ufs -s 1G ad4s1

gpart add -t freebsd-swap -s 2G ad4s1
# 2GB for swap
gpart add -t freebsd-ufs -s 2G ad4s1
# 2GB for /var
gpart add -t freebsd-ufs ad4s1
# all rest for /usr

#install bootcode
gpart bootcode -p /boot/boot -i 1 ad4s1
gpart set -a active -i 	ad4

cat <<EOF >/install.cfg
# This is the installation configuration file for our rackmounted FreeBSD
# cluster machines

# Turn on extra debugging.
debug=yes

#releaseName 8.0-RELEASE


################################
# My host specific data
#hostname=dragonfly
#domainname=cs.duke.edu
#nameserver=152.3.145.240
#defaultrouter=152.3.145.240
#ipaddr=152.3.145.64
#netmask=255.255.255.0
################################
tryDHCP=NO

################################
# Which installation device to use
# ftp://ftp.smr.ru/pub/0/FreeBSD/current/src/release/sysinstall/sysinstall.h
_ftpPath=ftp://ftp2.freebsd.org/pub/FreeBSD/
#_httpPath=ftp://ftp2.freebsd.org/pub/FreeBSD/
#httpProxy=192.168.2.10:800
netDev=em0
mediaSetFTP
#mediaSetHTTP

################################

################################
# Select which distributions we want.
#dists= bin doc games manpages catpages proflibs dict info des compat1x compat20 compat21 X331bin X331cfg X331doc X331html X331lib X331lkit X331man X331prog X331ps X331set X331VG16 X331nest X331vfb X331fnts X331f100 X331fcyr X331fscl X331fnon sinclude
#distSetCustom
distSetMinimum
################################

################################
# Now set the parameters for the partition editor on ad4.
disk=ad4
partition=all
#http://www.mail-archive.com/freebsd-questions@freebsd.org/msg212036.html
bootManager=standard
diskPartitionEditor
#diskPartitionWrite

################################

################################
# All sizes are expressed in 512 byte blocks!
#
# A 960MB root partition, followed by a 0.5G swap partition, followed by
# a 1G /var, and a /usr using all the remaining space on the disk
#
ad4s1-1=ufs 1966080 /mnt
ad4s1-2=swap 1048576 none
ad4s1-3=ufs 2097152 /mnt/var
ad4s1-4=ufs 0 /mnt/usr
# Let's do it!


diskLabelEditor
diskLabelCommit

#http://unix.derkeiler.com/Mailing-Lists/FreeBSD/questions/2010-11/msg00420.html
installRoot=/mnt
#

# OK, everything is set.  Do it!
installCommit


# Install some packages at the end.
# package=LPRng-3.2.3
# packageAdd


# Install some packages at the end.

#
# this last package is special.  It is used to configure the machine.
# it installs several files (like /root/.rhosts) an its installation
# script tweaks several options in /etc/rc.conf
#
#package=ari-0.0
#packageAdd

EOF

sysinstall configFile=/install.cfg loadConfig


#http://www.daemonforums.org/showthread.php?t=4389

cd /mnt/boot
cp -Rp GENERIC/* kernel/

#For some reason this is the disk layout the sysinstall creates

cat <<EOF > /mnt/etc/fstab
/dev/ad4s1b  none            swap    sw              0       0
/dev/ad4s1d / ufs rw 0 0
/dev/ad4s1f /usr ufs rw 0 0
/dev/ad4s1e /var ufs rw 0 0
EOF


# boot0cfg -B ad4
#make the menu appear

# Booting mentions an error
# Invalid partition
# FAILS WITH: 0:ad(0,a)/boot/kernel/kernel
# WORKS WITH: 0:ad(4,d)/boot/loader

#http://www.mail-archive.com/freebsd-questions@freebsd.org/msg72530.html
cat  <<EOF > /mnt/boot/loader.conf
#geom_label_load="YES"
#root_disk_unit="4"
#currdev="disk4s1d"
#rootdev="disk4s1d"
#vfs.root.mountfrom="ufs:/dev/ad4s1d"
EOF

#activate dhcp
cat <<EOF > /mnt/etc/rc.conf
ifconfig_DEFAULT="DHCP"
EOF


#The vi edit program needs a /var/tmp/vi.recover file.

mkdir -p /mnt/usr/local/etc/rc.d/
cd /mnt/usr/local/etc/rc.d/
cat  <<EOF > mkvirecover
#!/bin/sh
# PROVIDE: mkvirecover
# REQUIRE: mountcritremote
# BEFORE: DAEMON virecover


. /etc/rc.subr

name="mkvirecover"
stop_cmd=":"
start_cmd="mkvirecover_start"

mkvirecover_start()
{
[ -d /var/tmp/vi.recover ] || mkdir -m 1777 /var/tmp/vi.recover
echo '.'
}

load_rc_config "\$name"
run_rc_command "\$1"
EOF

chmod 555 /mnt/usr/local/etc/rc.d/mkvirecover
