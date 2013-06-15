#!/bin/bash

# Requires
#   reboot.sh

# Delete all veewee related files that were copied over, including this script
rm -rf /root/{*,.v*}

# Zero out the free space to save space in the final image
dd if=/dev/zero of=/tmp/clean bs=1M
rm -f /tmp/clean
