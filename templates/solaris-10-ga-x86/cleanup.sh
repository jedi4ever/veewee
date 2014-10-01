#!/bin/sh

# Standard clean up (when called during the build)
if [ $# -eq 0 ]; then
  rm -rf VBoxGuestAdditions_*.iso
  { sleep 1; /usr/sbin/reboot; } >/dev/null &
  exit 0
fi

# Additional clean up (to execute before the export, making sure root uid is used)
while getopts :f opt; do
  case $opt in
    f) # Apply full clean up
      echo "CLEANING before the export"
      pfexec /usr/sbin/poweroff >/dev/null
    ;;
  esac
done
