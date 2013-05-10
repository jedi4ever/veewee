#!/bin/bash

# fill all free hdd space with zeros
dd if=/dev/zero of=/boot/EMPTY bs=1M
rm -f /boot/EMPTY

dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# fill all swap space with zeros and recreate swap
swapoff /dev/sda3
shred -n 0 -z /dev/sda3
mkswap /dev/sda3


#clean root
rm /root/*

exit
