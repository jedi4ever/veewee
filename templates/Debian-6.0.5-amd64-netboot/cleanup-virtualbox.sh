if test -f .vbox_version ; then
# Cleanup Virtualbox
VBOX_VERSION=$(cat .vbox_version)
VBOX_ISO=VBoxGuestAdditions_$VBOX_VERSION.iso
rm $VBOX_ISO
fi
