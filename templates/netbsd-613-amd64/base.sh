PATH=/usr/bin:/bin:/usr/pkg/bin:/usr/sbin:/sbin:/usr/pkg/sbin

# set PKG_PATH
echo "PKG_PATH=http://ftp.NetBSD.org/pub/pkgsrc/packages/NetBSD/`uname -m`/`uname -r | cut -d. -f1-2`/All" > /etc/pkg_install.conf

# install packages
pkg_add sudo wget curl bash vim rsync ruby

# sudoers
echo "%wheel ALL=(ALL) NOPASSWD: SETENV: ALL" > /usr/pkg/etc/sudoers.d/veewee
chmod o-rwx /usr/pkg/etc/sudoers.d/veewee
