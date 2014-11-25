#!/bin/bash
source /etc/profile

# remove kernel source ( for less disk usage.)
chroot "$chroot" /bin/bash <<DATAEOF
pushd /usr/src/linux
make clean
popd
emerge -C sys-kernel/gentoo-sources
DATAEOF
