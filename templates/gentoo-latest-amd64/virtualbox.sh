#!/bin/bash
source /etc/profile

# add package keywords
cat <<DATAEOF >> "$chroot/etc/portage/package.keywords"
app-emulation/virtualbox-guest-additions ~amd64
DATAEOF

# unmask
cat <<DATAEOF >> "$chroot/etc/portage/package.unmask"
>=app-emulation/virtualbox-guest-additions-4.2.0
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
