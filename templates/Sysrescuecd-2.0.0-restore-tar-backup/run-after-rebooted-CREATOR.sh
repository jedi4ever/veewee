#! /bin/sh -xv

MAKESELF=$1

if [ ! -x $MAKESELF ]; then
  echo "ERROR - Expected to see makeself.sh at '$MAKESELF'"
  echo "Download that from https://github.com/megastep/makeself"
  exit 1
fi

~/SoftwareDevelopment/makeself/makeself.sh run-after-rebooted run-after-rebooted.sh "Files to be run after rebooted, in the restored system" ./run-after-rebooted-runner.sh
