Veewee::Session.declare( {
  :cpu_count => '8', :memory_size=> '1536',
  :disk_size => '10140', :disk_format => 'VDI',:hostiocache => 'off',
  :os_type_id => 'Gentoo_64', # Funtoo is a GIT based gentoo derivative
  :iso_file => "install-amd64-minimal-20111208.iso",
  :iso_src => "http://ftp.osuosl.org/pub/gentoo/releases/amd64/autobuilds/20111208/install-amd64-minimal-20111208.iso",
  :iso_md5 => "8c4e10aaaa7cce35503c0d23b4e0a42a",
  :iso_download_timeout => "1000",
  :boot_wait => "4",
  :boot_cmd_sequence => [
        '<Wait>'*4,
        'gentoo-nofb<Enter>', # boot gentoo no frame buffer mode option
        '<Wait>'*45,
        '<Enter>',            # asks about your keyboard, take the default
        '<Wait>'*45,
        '<Enter><Wait>',      # just in case we are out of sync
        'net-setup eth0<Enter>',
        '<Wait><Enter>',
        '2<Enter>',           # Set up the NIC card with DHCP
        '1<Enter>',
	'<Wait><Wait>ifconfig -a <Enter>',
        'passwd<Enter><Wait><Wait>',
	'vagrant<Enter><Wait>',
	'vagrant<Enter><Wait>',
        '/etc/init.d/sshd start<Enter><Wait><Wait>'
    ],
  :kickstart_port => "7122", :kickstart_timeout => "10000",:kickstart_file => "",
  :ssh_login_timeout => "10000",:ssh_user => "root", :ssh_password => "vagrant",:ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "cat '%f'|su -",
  :shutdown_cmd => "shutdown -p now",
  :postinstall_files => [ "postinstall.sh", "postinstall2.sh" ], :postinstall_timeout => "15000"
   }
)
