#!/bin/bash
source /etc/profile

# remove git's dependency on 50+ perl modules.
cat <<DATAEOF >> "$chroot/etc/portage/package.use/git"
# git with no dependency
dev-vcs/git -curl -perl -gpg -webdav

# git with massive dependency with subversion support
#dev-vcs/git -gpg perl -webdav subversion
#>=dev-vcs/subversion-1.7.13 -dso perl
DATAEOF

# install git
chroot "$chroot" emerge dev-vcs/git

# for git-quiltimport
#chroot "$chroot" emerge dev-util/quilt
# for git-instaweb : || ( www-servers/lighttpd  www-servers/apache)
#chroot "$chroot" emerge www-servers/lighttpd

