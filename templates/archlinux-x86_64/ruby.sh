#!/bin/bash

# Requires
#   reboot.sh

# Uncomment this and delete the Ruby 1.9 install section below when Chef
# supports Ruby 2.0
#pacman -S --noconfirm ruby

# We can install Ruby 1.9 either using an older PKGBUILD or download the
# package from the Arch Rollback Machine. Using the Rollback Machine saves from
# having to compile Ruby for every new VM.
arch="$(uname -m)"
package="ruby-1.9.3_p392-1-${arch}.pkg.tar.xz"

cd /tmp
wget "http://arm.konnichi.com/2013/03/23/extra/os/${arch}/${package}"
pacman -U --noconfirm "${package}"

# Add ruby to Pacman's ignore list so it does not get upgraded to 2.0
sed -ri 's/^#?(IgnorePkg.*)/\1 ruby/' /etc/pacman.conf

# Don't install RDoc and RI to save time and space
cat <<EOF >> /etc/gemrc
install: --no-rdoc --no-ri
update:  --no-rdoc --no-ri
EOF
