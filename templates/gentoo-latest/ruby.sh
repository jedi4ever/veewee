#!/bin/bash
source /etc/profile

cat <<DATAEOF >> "$chroot/etc/portage/make.conf"
# use ruby 2.0
RUBY_TARGETS="ruby20"
DATAEOF

cat <<DATAEOF >> "$chroot/etc/portage/package.accept_keywords/ruby"
dev-util/ragel ~x86 ~amd64
DATAEOF

chroot "$chroot" /bin/bash <<DATAEOF
env-update && source /etc/profile
emerge --autounmask-write ruby:2.0
eselect ruby set ruby20
DATAEOF
