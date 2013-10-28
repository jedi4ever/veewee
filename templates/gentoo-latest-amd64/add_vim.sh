#!/bin/bash
source /etc/profile

# add required use flags and keywords
#cat <<DATAEOF >> "$chroot/etc/portage/package.use/vim"
#app-editors/vim minimal
#DATAEOF

cat <<DATAEOF >> "$chroot/etc/portage/package.accept_keywords/vim"
app-vim/bash-support ~x86 ~amd64
DATAEOF

# install vim
chroot "$chroot" emerge app-editors/vim


# install vim plugins
chroot "$chroot" emerge app-vim/puppet-syntax app-vim/bash-support

# install spf13 (experimental)
#chroot "$chroot" emerge dev-vcs/git # be aware of huge dependency
#chroot "$chroot" wget --no-check-certificate -qO- http://j.mp/spf13-vim3
