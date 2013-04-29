#!/bin/bash
source /etc/profile

# install nfs utilities and automount support
chroot "$chroot" emerge net-fs/nfs-utils

# Gentoo has sandbox issues with latest autofs builds
# https://bugs.gentoo.org/show_bug.cgi?id=453778
chroot "$chroot" /bin/bash <<DATAEOF
FEATURES="-sandbox" emerge net-fs/autofs
DATAEOF
