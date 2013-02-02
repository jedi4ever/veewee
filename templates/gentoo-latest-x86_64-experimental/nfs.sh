#!/bin/bash
source /etc/profile

# install nfs utilities and automount support
chroot "$chroot" emerge net-fs/nfs-utils net-fs/autofs