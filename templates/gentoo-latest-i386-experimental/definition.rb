Veewee::Session.declare( {
  :cpu_count => '1', :memory_size=> '768',
  :disk_size => '10140', :disk_format => 'VDI',:hostiocache => 'off',
  :os_type_id => 'Gentoo',
  :iso_file => "install-x86-minimal-20110726.iso",
  :iso_src => "http://distfiles.gentoo.org/releases/x86/autobuilds/current-iso/install-x86-minimal-20110726.iso",
  :iso_md5 => "29fc74988e7f86417395e376afc1af47",
  :iso_download_timeout => "1000",
  :boot_wait => "120",:boot_cmd_sequence => [
        'net-setup eth0<Enter>',
        '<Wait><Enter>',
        '2<Enter>',
        '1<Enter>',
	'<Wait><Wait>ifconfig -a <Enter>',
	#'sleep 5 ;curl http://%IP%:%PORT%/stages.sh -o stages.sh &&',
	#'bash stages.sh &<Enter>',
        'passwd<Enter><Wait><Wait>',
	'vagrant<Enter><Wait>',
	'vagrant<Enter><Wait>',
        '/etc/init.d/sshd start<Enter>'
    ],
  :kickstart_port => "7122", :kickstart_timeout => "10000",:kickstart_file => "",
  :ssh_login_timeout => "10000",:ssh_user => "root", :ssh_password => "vagrant",:ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "cat '%f'|su -",
  :shutdown_cmd => "shutdown -p now",
  :postinstall_files => [ "postinstall.sh"],:postinstall_timeout => "10000"
   }
)
