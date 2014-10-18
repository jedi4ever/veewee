Veewee::Session.declare({
  :cpu_count => '1', :memory_size=> '256', 
  :disk_size => '40960', :disk_format => 'VDI', :hostiocache => 'off',
  :os_type_id => 'OpenBSD_32',
  :iso_file => "openbsd50_32.iso",
  :iso_src => "http://ftp.plig.net/pub/OpenBSD/5.0/i386/install50.iso",
  :iso_md5 => "2f0cc4df7dfe095f15a8ddadf8a02f69",
  :iso_download_timeout => "1000",
  :boot_wait => "40", :boot_cmd_sequence => [
# I - install
   'I<Enter>',
# set the keyboard
   'us<Enter>',
# set the hostname
   'OpenBSD50-x32<Enter>',
# Which nic to config ? [em0]
   '<Enter>',
# do you want dhcp ? [dhcp]
   '<Enter>',
   '<Wait>'*5,
# IPV6 for em0 ? [none]
   'none<Enter>',
# Which other nic do you wish to configure [done]
   'done<Enter>',
# Manual netw configuration ? [no]
   'no<Enter>',
# Pw for root account
   'vagrant<Enter>',
   'vagrant<Enter>',
# Start sshd by default ? [yes]
   'yes<Enter>',
# Start ntpd by default ? [yes]
   'no<Enter>',
# Do you want the X window system [yes]
   'no<Enter>',
# Setup a user ?
   'vagrant<Enter>',
# Full username
   'vagrant<Enter>',
# Pw for this user
   'vagrant<Enter>',
   'vagrant<Enter>',
# Do you want to disable sshd for root ? [yes]
   'no<Enter>',
# What timezone are you in ?
   'GB<Enter>',
# Available disks [sd0]
   '<Enter>',
# Use DUIDs rather than device names in fstab ? [yes]
   '<Enter>',
# Use (W)whole disk or (E)edit MBR ? [whole]
   'W<Enter>',
# Use (A)auto layout ... ? [a]
   'A<Enter>',
   '<Wait>'*60,
# location of the sets [cd]
   'cd<Enter>',
# Available cd-roms : cd0
   '<Enter>',
# Pathname to sets ? [5.0/i386]
   '<Enter>',
# Remove games and X
   '-game50.tgz<Enter>',
   '-xbase50.tgz<Enter>',
   '-xetc50.tgz<Enter>',
   '-xshare50.tgz<Enter>',
   '-xfont50.tgz<Enter>',
   '-xserv50.tgz<Enter>',
   'done<Enter>',
   '<Wait>'*90,
# Done installing ?
   'done<Enter>',
   '<Wait>'*6,
# Install non-free firmware files on first boot ? [no] <-- don't know what this is so I'm saying no
   'no<Enter><Wait>',
   'reboot<Enter>'
  ],
  :kickstart_port => "7122", :kickstart_timeout => "300", :kickstart_file => "",
  :ssh_login_timeout => "10000", :ssh_user => "root", :ssh_password => "vagrant", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "sh '%f'",
  :shutdown_cmd => "/sbin/halt -p",
  :postinstall_files => [ "postinstall.sh"], :postinstall_timeout => "10000"
})
