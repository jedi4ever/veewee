cd /tmp
mkdir -p /mnt/cdrom
mount -o loop /home/veewee/linux.iso /mnt/cdrom
tar zxvf /mnt/cdrom/VMwareTools-*.tar.gz -C /tmp/
/tmp/vmware-tools-distrib/vmware-install.pl -d
rm /home/veewee/linux.iso
umount /mnt/cdrom
