Veewee::Session.declare({
  :cpu_count => '1', :memory_size=> '256',
  :disk_size => '40960', :disk_format => 'VDI', :hostiocache => 'off',
  :os_type_id => 'OpenBSD_64',
  :iso_file => "openbsd55_64.iso",
  :iso_src => "http://ftp3.usa.openbsd.org/pub/OpenBSD/5.5/amd64/install55.iso",
  :iso_sha256 => "cc465ce3f8397883e91c6e1a8a98b1b3507a338984bbfe8978050c5f8fdcaf3f",
  :iso_download_timeout => "1000",
  :boot_wait => "50", :boot_cmd_sequence => [
# I - install
   'I<Enter>',
# set the keyboard
   'us<Enter>',
# set the hostname
   'OpenBSD55-x64<Enter>',
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
   '<Wait>'*70,
# location of the sets [cd]
   'cd<Enter>',
# Available cd-roms : cd0
   '<Enter>',
# Pathname to sets ? [5.5/amd64]
   '<Enter>',
# Remove games and X
   '-game55.tgz<Enter>',
   '-xbase55.tgz<Enter>',
   '-xetc55.tgz<Enter>',
   '-xshare55.tgz<Enter>',
   '-xfont55.tgz<Enter>',
   '-xserv55.tgz<Enter>',
   'done<Enter>',
   '<Wait>',
# CD does not contain SHA256.sig (5.5) Continue without verification?
   'yes<Enter>',
# Done installing ?
   'done<Enter>',
   '<Wait>'*6,
# Time appears wrong. Set to ...? [yes]
   'yes<Enter><Wait>',
   '<Wait>'*6,
   'reboot<Enter>',
   '<Wait>'*6
  ],
  :kickstart_port => "7122", :kickstart_timeout => "300", :kickstart_file => "",
  :ssh_login_timeout => "10000", :ssh_user => "root", :ssh_password => "vagrant", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "sh '%f'",
  :shutdown_cmd => "/sbin/halt -p",
  :postinstall_files => [
    "base.sh",
    "vagrant.sh",
    "ruby.sh",
    "puppet.sh",
    "chef.sh"
  ],
  :postinstall_timeout => "10000"
})
