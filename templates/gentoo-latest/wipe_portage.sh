#!/bin/bash
source /etc/profile

cat <<DATAEOF > "$chroot/etc/portage/rsync_excludes.sh"
#!/bin/sh
if [ ! -f /usr/bin/equery ]
  then
    /bin/echo "/usr/bin/equery does NOT exist!"
    /bin/echo " Please emerge app-portage/gentoolkit"
    exit 1
fi

/bin/echo ""
/bin/echo "creating list of installed packages..."

/usr/bin/equery list '*' | \
  /bin/sed -e 's/-[0-9].*$//' \
           -e '/* installed packages/d' \
> .rsync_exclude.tmp

/bin/echo "building rsync_excludes..."

cat .rsync_exclude.tmp | sed -e 's/^/+ /' > rsync_excludes

/bin/echo "- /*-*/*" >> rsync_excludes

cat .rsync_exclude.tmp | \
  sed -e 's/^/+ metadata\/cache\//' \
      -e 's/$/*/' \
>> rsync_excludes

/bin/echo "- licenses**"          >> rsync_excludes
/bin/echo "- metadata/cache/*/*"  >> rsync_excludes
/bin/echo "- metadata/timestamp*" >> rsync_excludes
/bin/echo "- virtual/*"           >> rsync_excludes

/bin/echo "+ profiles/default/linux/alpha/*"    >> rsync_excludes
/bin/echo "+ profiles/default/linux/arm/*"      >> rsync_excludes
/bin/echo "+ profiles/default/linux/hppa/*"     >> rsync_excludes
/bin/echo "+ profiles/default/linux/ia64/*"     >> rsync_excludes
/bin/echo "+ profiles/default/linux/m68k/*"     >> rsync_excludes
/bin/echo "+ profiles/default/linux/mips/*"     >> rsync_excludes
/bin/echo "+ profiles/default/linux/powerpc/*"  >> rsync_excludes
/bin/echo "+ profiles/default/linux/s390/*"     >> rsync_excludes
/bin/echo "+ profiles/default/linux/sh/*"       >> rsync_excludes
/bin/echo "+ profiles/default/linux/sparc/*"    >> rsync_excludes
/bin/echo "+ profiles/default/linux/use.mask/*" >> rsync_excludes
#/bin/echo "+ profiles/default/linux/amd64/*"    >> rsync_excludes
#/bin/echo "+ profiles/default/linux/x86/*"      >> rsync_excludes

/bin/echo "+ profiles/arch/alpha/*"      >> rsync_excludes
#/bin/echo "+ profiles/arch/amd64/*"      >> rsync_excludes
#/bin/echo "+ profiles/arch/amd64-fbsd/*" >> rsync_excludes
/bin/echo "+ profiles/arch/arm/*"        >> rsync_excludes
#/bin/echo "+ profiles/arch/base/*"       >> rsync_excludes
/bin/echo "+ profiles/arch/hppa/*"       >> rsync_excludes
#/bin/echo "+ profiles/arch/ia64/*"       >> rsync_excludes
/bin/echo "+ profiles/arch/m68k/*"       >> rsync_excludes
/bin/echo "+ profiles/arch/mips/*"       >> rsync_excludes
/bin/echo "+ profiles/arch/powerpc/*"    >> rsync_excludes
/bin/echo "+ profiles/arch/s390/*"       >> rsync_excludes
/bin/echo "+ profiles/arch/sh/*"         >> rsync_excludes
/bin/echo "+ profiles/arch/sparc/*"      >> rsync_excludes
/bin/echo "+ profiles/arch/sparc-fbsd/*" >> rsync_excludes
#/bin/echo "+ profiles/arch/x86/*"        >> rsync_excludes
#/bin/echo "+ profiles/arch/x86-fbsd/*"   >> rsync_excludes

rm -f .rsync_exclude.tmp

/bin/echo "done"
DATAEOF

cat <<DATAEOF >> "$chroot/etc/portage/make.conf"
PORTAGE_RSYNC_EXTRA_OPTS="--exclude-from=/etc/portage/rsync_excludes --delete-excluded --delete-before"
DATAEOF

# compact the portage
chroot "$chroot" /bin/bash <<DATAEOF
cd /etc/portage
. ./rsync_excludes.sh
echo "Cleaning main portage '/usr/portage' ..."
emerge -q --sync
emerge --metadata
egencache --update --repo gentoo
mv rsync_excludes rsync_excludes.all
touch rsync_excludes
echo "The main portage has been cleaned up. '/usr/portage' will be repopulated on next 'emerge --sync'."
DATAEOF
