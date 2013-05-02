#!/bin/bash

# Requires
#   ruby.sh
#   aur.sh

# ruby-hiera is specified as a makedepend for ruby-hiera-json. But packer tries
# to install ruby-hiera-json first and fails. Install ruby-hiera first so
# puppet installs cleanly first time.
packer -S --noconfirm --noedit ruby-hiera
# Mark ruby-hiera as a dependency package manually since packer does not pass
# the --asdeps flag https://github.com/keenerd/packer/pull/100
pacman -D --asdeps ruby-hiera

# Install puppet
packer -S --noconfirm --noedit puppet
