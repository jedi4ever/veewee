#!/bin/bash
source /etc/profile

/sbin/reboot
ps aux | grep sshd | grep -v grep | awk '{print $2}' | xargs kill
