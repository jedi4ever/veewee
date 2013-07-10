# Dependencies
yum install -y tar bzip2 kernel-devel gcc
# Installing the virtualbox guest additions
mount /dev/sr1 /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
