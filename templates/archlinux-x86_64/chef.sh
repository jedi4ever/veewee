#!/bin/bash

# Requires
#   ruby.sh
#   aur.sh

# Don't install ruby-highline from Arch repositories since it was built against
# Ruby 2.0. Build from source. Remove this section when Chef supports Ruby 2.0.
mkdir -p /tmp/ruby-highline
wget 'https://projects.archlinux.org/svntogit/community.git/plain/trunk/PKGBUILD?h=packages/ruby-highline&id=49e00a9ea7ffa267048aa7fc7a82a0427c10958d' \
  -O /tmp/ruby-highline/PKGBUILD
chown -R veewee:veewee /tmp/ruby-highline
cd /tmp/ruby-highline
su veewee -c 'makepkg -si --noconfirm'
cd -
rm -rf /tmp/ruby-highline

# Change TMPDIR for packer to stop /tmp from filling up during install
export TMPDIR=$(pwd)/tmp
mkdir -p $TMPDIR

# Packer does not always seem to install the dependencies in the correct order.
# For example, in a case where A requires B, C and B requires C, packer seems
# to install B then C which causes B's installation to fail, leading to an
# installation failure for A. This works around that problem.
packer -S --noconfirm --noedit ruby-net-ssh ruby-ohai
pacman -D --asdeps ruby-net-ssh ruby-ohai

packer -S --noconfirm --noedit ruby-chef

rm -rf $TMPDIR
