#!/bin/bash

# Requires
#   ruby.sh
#   aur.sh

# Packer does not always seem to install the dependencies in the correct order.
# For example, in a case where A requires B, C and B requires C, packer seems
# to install B then C which causes B's installation to fail, leading to an
# installation failure for A. This works around that problem.
packer -S --noconfirm --noedit ruby-net-ssh ruby-ohai
pacman -D --asdeps ruby-net-ssh ruby-ohai

packer -S --noconfirm --noedit ruby-chef
