Veewee::Definition.declare({
  :cpu_count => '1', :memory_size=> '256', 
  :disk_size => '10140', :disk_format => 'VDI', :hostiocache => 'off',
  :os_type_id => 'FreeBSD_64',
  :iso_file => "mfsbsd-8.2-amd64.iso",
  :iso_src => "http://mfsbsd.vx.sk/iso/mfsbsd-8.2-amd64.iso",
  :iso_md5 => "3296cf0e5844",
  :iso_download_timeout => "1000",
  :boot_wait => "10", :boot_cmd_sequence => [
   '<Enter>'
  ],
  :kickstart_port => "7122", :kickstart_timeout => "10000", :kickstart_file => "",
  :ssh_login_timeout => "10000", :ssh_user => "root", :ssh_password => "mfsroot", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "sh '%f'",
  :shutdown_cmd => "shutdown -H",
  :postinstall_files => [ "postinstall.sh"], :postinstall_timeout => "10000"
})
#'setkmap=us dodhcp=eth0 dhcphostname=%NAME% ar_source=http://%IP%:%PORT%/ autoruns=0 rootpass=vagrant',
