#!/bin/bash

# Requires
#   ssh.sh
#   bootloader.sh

# https://bugs.archlinux.org/task/31250
# Since systemd reboot does not notify/close SSH client connections, veewee
# never tries to reconnect to the VM post-reboot. This flaky workaround tries
# to ensure that client connections have been disconnected prior to reboot.
cp /usr/lib/systemd/system/systemd-user-sessions.service /etc/systemd/system
sed -i 's/\(After=remote-fs.target\)/\1 network.target/' /etc/systemd/system/systemd-user-sessions.service
systemctl daemon-reload
rm -f /etc/systemd/system/systemd-user-sessions.service

if [ -d /mnt/root ]; then
  # Since /mnt/root exists, we must be inside a chroot. Copy over scripts so
  # they're available post-reboot.
  cp -r /root/{*,.v*} /mnt/root
fi

reboot
