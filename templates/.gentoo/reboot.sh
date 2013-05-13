#!/bin/bash
source /etc/profile

cp /root/* /mnt/gentoo/root/
cp /etc/profile.d/* /mnt/gentoo/etc/profile.d/

/etc/init.d/sshd stop && /sbin/reboot
