Restore a TBZ instead of an ISO

By Martin R.J. Cleaver (https://github.com/mrjcleaver)
Blended Perspectives Inc.

Preamble Per https://github.com/jedi4ever/veewee/issues/475
--------

[mrjcleaver]
>> My hosting provider has provided me with a tgz off a clean install of
>> their virtual machine, rather than an ISO. It contains listing entries
>> for device nodes that can't be represented on the ISO.
>> Is there a way to use this?

[jedi4ever]
> First thought - create a definition with the tar ball as an ISO. Use
> the sys rescue CD to boot & format the disk and untar the tarball ?



To Run
------
0. Have working vagrant, veewee, makeself and rvm installations
- Download makeself.sh from https://github.com/megastep/makeself
- put makeself as a sibling directory to veewee
1. Edit restorebackup.sh and set the BACKUPLOCATION
2. Edit MAKE-TEMPLATE.sh and fix up:
- paths
- which subtemplate you want to use, to go in the payload
3. If necessary*, edit the scripts in run-after-rebooted
4. Run MAKE-TEMPLATE.sh - this creates the payload 
5. Watch the machine boot off the SysRescue ISO, it will restore the TBZ file
6. Reboot it again, this time off the Hard drive, and log you in as root
7. Run /root/run-after-rebooted.sh

Theory of Operation
-------------------

This uses a subtemplate, which is just another veewee template that does the
distro-specific work. It is carried into the restored system as a payload.

run-after-rebooted.sh is the makeself.sh script/archive, runnable payload.
This is built using the contents of the directory 'run-after-rebooted' plus
the subtemplate you selected. It runs the numbered scripts in number sequence.

Booting Sysrescue disk / postinstall formats the disk, mounts as /mnt/rootfs,
installs the backup + carries a payload into the newly restored rootfs, then
dumps a copy of the payload (including subtemplate) plus Virtualbox Guest 
ISO into root's home directory.

When you boot again, from the restored backup, run the payload script again, this time manually. (cd /root; sh ./run-after-rebooted.sh) 
As /mnt/rootfs won't exist, when it runs this time it knows to extract the
payload and runs the commands of the subtemplate.

Once all the subtemplate scripts have finished, in theory you have a restored
TBZ file that also has the effects of the subtemplate applied to it. 

1. Boots Sysrescuecd ISO

definition.rb:
a. formatandmountdisk.sh: /dev/sda,  mounts as /mnt/rootfs, /mnt/boot + swap
b. restorebackup.sh: Expands TBZ
c. installgrub.sh: Sets up Grub (broken)
d. run-after-rebooted.sh: Copies the payload + Guest ISO into /mnt/rootfs
e. manual reboot

2. Restart - Boots /dev/sda 

a. passwd (Set the passwd for root!)
b. cd /root
c. sh run-after-rebooted.sh:
 i.  Extracts the payload, and runs each numbered script. Uses Guest ISO
 ii. Numbered scripts fix any prerequisites for running payloaded subtemplate
 iii. One of these scripts is to call each subtemplate/*.sh in correct order

3. veewee box validate restore

4. shutdown the box 

4. veewee box export restore  


`
Known Issues
------------
- grub doesn't work the first time
-- To restart, You may have to manually get the linux system to boot off the
-- right partition (use option E, pick 32/64 bit kernel)
- vboxadd (Virtualbox Guest Additions) don't work for me (this is likely 
  to do with my restored TBZ). This results in the veewee-validation test
  failing. (The others pass)
- This system is a cuckoo: it starts off as sysrescue and ends up as whatever
  is in the TBZ. Now, sysrescue is GenToo, but the TBZ is likely to contain
  something different. This makes the parent definition.rb file incapable 
  of controlling the chick... e.g. veewee tries to use the wrong shutdown
  syntax. This only affects 

Caveats
-------
- This was built on my 10.6.8 Mac for my Debian 6.0.6 machines. 
- Built in early Jan 2013 
- YMMV. Caveat Emptor ;)
- The numbered scripts system and calling of subtemplates (built in sh)
  actually replicates some functionality in veewee.

