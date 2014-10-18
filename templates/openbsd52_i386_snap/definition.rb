Veewee::Session.declare({
  :cpu_count => '1', :memory_size=> '256',
  :disk_size => '40960', :disk_format => 'VDI', :hostiocache => 'off',
  :os_type_id => 'OpenBSD',
  :iso_file => "openbsd52snap_32.iso",
  :iso_src => "http://ftp3.usa.openbsd.org/pub/OpenBSD/snapshots/i386/install52.iso",
  :iso_md5 => "a10f51d910052b477147e198c08089f8",
  :iso_download_timeout => "1000",
  :boot_wait => "80", :boot_cmd_sequence => [
# I - install
   'I<Enter>',
# set the keyboard
   'us<Enter>',
# set the hostname
   'OpenBSD52snap-x32<Enter>',
# Which nic to config ? [em0]
   '<Enter>',
# do you want dhcp ? [dhcp]
   '<Enter>',
   '<Wait>'*5,
# IPV6 for em0 ? [none]
   'none<Enter>',
# Which other nic do you wish to configure [done]
   'done<Enter>',
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
# Pathname to sets ? [5.2/i386]
   '<Enter>',
# Remove games and X
   '-game52.tgz<Enter>',
   '-xbase52.tgz<Enter>',
   '-xetc52.tgz<Enter>',
   '-xshare52.tgz<Enter>',
   '-xfont52.tgz<Enter>',
   '-xserv52.tgz<Enter>',
   'done<Enter>',
   '<Wait>'*90,
# Done installing ?
   'done<Enter>',
   '<Wait>'*6,
   'reboot<Enter>',
   '<Wait>'*6
  ],
  :kickstart_port => "7122", :kickstart_timeout => "300", :kickstart_file => "",
  :ssh_login_timeout => "10000", :ssh_user => "root", :ssh_password => "vagrant", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "sh '%f'",
  :shutdown_cmd => "/sbin/halt -p",
  :postinstall_files => [ "postinstall.sh"], :postinstall_timeout => "10000"
})
