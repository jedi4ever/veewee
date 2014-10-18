Veewee::Session.declare({
  :cpu_count => '1', :memory_size=> '256',
  :disk_size => '40960', :disk_format => 'VDI', :hostiocache => 'off',
  :os_type_id => 'NetBSD_64',
  :iso_file => "netbsd613_64.iso",
  :iso_src => "http://iso.netbsd.org/pub/NetBSD/iso/6.1.3/NetBSD-6.1.3-amd64.iso",
  :iso_sha256 => "830dd6871e228ba53522b1148e0ba87df9d3024b45bc12a630406257d0d93ce5",
  :iso_download_timeout => "1000",
  :boot_wait => "10", :boot_cmd_sequence => [
# 1. Install NetBSD
   '1',
   '<Wait>'*20,
# a: Installation messages in English
   '<Enter>',
# a: unchanged
   '<Enter>',
# a: Install NetBSD to hard disk
   '<Enter>',
# Shall we continue?  b: Yes
   'b<Enter>',
# >Hit enter to continue
   '<Enter>',
# Select your distribution  b: Installation without X11
   'b<Enter>',
# a: This is the correct geometry
   '<Enter>',
# b: Use the entire disk
   'b<Enter>',
# Do you want to install the NetBSD bootcode?  a: Yes
   '<Enter>',
# Choose your installation  b: Use existing partition sizes
   'b<Enter>',
# x: Partition sizes ok
   'x<Enter>',
# Please enter a name for your NetBSD disk [VBOX HARDDISK  ]:
   '<Enter>',
# Shall we continue?
   'b<Enter>',
   '<Wait>'*15,
# Bootblocks selection
   'x<Enter>',
# Install from  a: CD-ROM / DVD / install image media
   '<Enter>',
   '<Wait>'*30,
# Hit enter to continue
   '<Enter>',
# d: Change root password
   'd<Enter>',
# yes or no?  a: Yes
   '<Enter>',
# Changing local password for root.
   'vagrant<Enter>',
   'vagrant<Enter>',
   'vagrant<Enter>',
# g: Enable sshd
   'g<Enter>',
# a: Configure network
   'a<Enter>',
# Which device shall I use? [wm0]
   '<Enter>',
# Network media type [autoselect]:
   '<Enter>',
# Perform DHCP autoconfiguration?  a: Yes
   '<Enter>',
   '<Wait>'*5,
# Your DNS domain [example.com]: 
   '<Enter>',
# Your host name:
   'NetBSD61-amd64<Enter>',
# Perform IPv6 autoconfiguration?  a: No
   '<Enter>',
# Are they OK?  a: Yes
   '<Enter>',
   '<Wait>'*10,
# Is the network information you entered accurate for thes machine
# in regular operation and do you want it installed in /etc?  a: Yes
   '<Enter>',
# x: Finished configuring
   'x<Enter>',
# Hit enter to continue
   '<Enter>',
# e: Utility menu
   'e<Enter>',
# a: Run /bin/sh
   'a<Enter>',
# put "PermitRootLogin" on /etc/ssh/sshd_config
   'mount /dev/wd0a /mnt<Enter>',
   'echo "PermitRootLogin yes" >> /mnt/etc/ssh/sshd_config<Enter>',
   'umount /mnt<Enter>',
   'reboot<Enter>'
  ],
  :kickstart_port => "7122", :kickstart_timeout => "300", :kickstart_file => "",
  :ssh_login_timeout => "10000", :ssh_user => "root", :ssh_password => "vagrant", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "sh '%f'",
  :shutdown_cmd => "/sbin/shutdown -p now",
  :postinstall_files => [
    "base.sh",
    "vagrant.sh",
    "chef.sh"
  ],
  :postinstall_timeout => "10000"
})
