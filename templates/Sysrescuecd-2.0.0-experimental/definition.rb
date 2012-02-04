Veewee::Definition.declare({
  :cpu_count => '1', :memory_size=> '256', 
  :disk_size => '10140', :disk_format => 'VDI', :hostiocache => 'off',
  :os_type_id => 'Linux',
  :iso_file => "systemrescuecd-x86-2.0.0.iso",
  :iso_src => "http://downloads.sourceforge.net/project/systemrescuecd/sysresccd-x86/2.0.0/systemrescuecd-x86-2.0.0.iso",
  :iso_md5 => "51012e0bb943cff6367e5cea3a61cdbe",
  :iso_download_timeout => "1000",
  :boot_wait => "10", :boot_cmd_sequence => [
    '<Tab> ',
    'setkmap=us dodhcp=eth0 dhcphostname=%NAME% ar_source=http://%IP%:%PORT%/ autoruns=0 rootpass=vagrant',
    '<Enter>'
  ],
  :kickstart_port => "7122", :kickstart_timeout => "10000", :kickstart_file => "autorun0",
  :ssh_login_timeout => "10000", :ssh_user => "root", :ssh_password => "vagrant", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "sh '%f'",
  :shutdown_cmd => "shutdown -H",
  :postinstall_files => [ ], :postinstall_timeout => "10000"
})
