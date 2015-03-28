# Zero out the free space to save space in the final image:
cat /dev/zero > /EMPTY; sync; sleep 3; sync; rm -f /EMPTY
