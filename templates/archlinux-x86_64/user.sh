#!/bin/bash

# Requires
#   reboot.sh

useradd -m -G wheel -r veewee
passwd -d veewee
passwd veewee<<EOF
veewee
veewee
EOF
