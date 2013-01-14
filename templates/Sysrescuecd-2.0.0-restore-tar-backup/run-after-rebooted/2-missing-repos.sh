#! /bin/sh -xv

#Yeah, there has to be an easier way, but I don't know of one
#http://howto.biapy.com/en/debian-gnu-linux/system/software/setup-the-contrib-and-non-free-debian-repositories

DEBIAN_VERSION="$(command lsb_release -cs)"
MIRROR=$(command egrep "^deb.*${DEBIAN_VERSION}" '/etc/apt/sources.list' \
    | command egrep -v "updates|-src|cdrom" \
    | cut --delimiter=" " --fields=2)

echo "# Debian contrib repository.
deb http://ftp.fr.debian.org/debian/ ${DEBIAN_VERSION} contrib
deb-src http://ftp.fr.debian.org/debian/ ${DEBIAN_VERSION} contrib

deb http://security.debian.org/ ${DEBIAN_VERSION}/updates contrib
deb-src http://security.debian.org/ ${DEBIAN_VERSION}/updates contrib

# ${DEBIAN_VERSION}-updates, previously known as 'volatile'
deb http://ftp.fr.debian.org/debian/ ${DEBIAN_VERSION}-updates contrib
deb-src http://ftp.fr.debian.org/debian/ ${DEBIAN_VERSION}-updates contrib" \
    > '/etc/apt/sources.list.d/contrib.list'


echo "# Debian non-free repository.
deb http://ftp.fr.debian.org/debian/ ${DEBIAN_VERSION} non-free
deb-src http://ftp.fr.debian.org/debian/ ${DEBIAN_VERSION} non-free

deb http://security.debian.org/ ${DEBIAN_VERSION}/updates non-free
deb-src http://security.debian.org/ ${DEBIAN_VERSION}/updates non-free

# ${DEBIAN_VERSION}-updates, previously known as 'volatile'
deb http://ftp.fr.debian.org/debian/ ${DEBIAN_VERSION}-updates non-free
deb-src http://ftp.fr.debian.org/debian/ ${DEBIAN_VERSION}-updates non-free" \
    > '/etc/apt/sources.list.d/non-free.list'

apt-get update



