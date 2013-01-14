#! /bin/sh -xv

# We run this twice:
# 1. under the recovery cd, (in which case it moves itself to the new rootfs)
# 2. after the recovered system has rebooted (in which case it unpacks itself)

TARGETMOUNT=/mnt/rootfs
ROOTHOME=/root
ROOTHOMEMOUNTED=$TARGETMOUNT$ROOTHOME

if [ -d $ROOTHOMEMOUNTED ]; then
  echo "Detected that the system is being recovered"
  mv -v /root/VBoxGuestAdditions*.iso $ROOTHOMEMOUNTED
  mv -v /root/run-after-rebooted.sh $ROOTHOMEMOUNTED
  echo "Resources copied to $ROOTHOMEMOUNTED"
  echo "You should be ready for a reboot!"
  exit 0
else 
  echo "Okay, now extracting the subtemplate"
  DIR=$ROOTHOME/vbox-subtemplate
  cd $DIR
  $ROOTHOME/run-after-rebooted.sh --tar xvf -C $DIR
  for script in ?-*.sh ; do
      sh $script
      if [ $? -ne 0]; then
	  echo "$script finished with non-zero ($?) exit code, aborting"
	  exit $?
      fi
  done
fi


