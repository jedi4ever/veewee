Veewee::Definition.declare({
  :cpu_count => '1', :memory_size=> '392',
  :disk_size => '10140', :disk_format => 'VDI', :hostiocache => 'off', :ioapic => 'on', :pae => 'on',
  :os_type_id => 'RedHat_64',
  :iso_file => "CentOS-6.0-x86_64-netinstall.iso",
  :iso_src => "http://vault.centos.org/6.0/isos/x86_64/CentOS-6.0-x86_64-netinstall.iso",
  :iso_md5 => "d13da95c29e585ee15cf403b89468243",
  :iso_download_timeout => 1000,
  :boot_wait => "15", :boot_cmd_sequence => [ '<Tab> text ks=http://%IP%:%PORT%/ks.cfg<Enter>' ],
  :kickstart_port => "7122", :kickstart_timeout => 10000, :kickstart_file => "ks.cfg",
  :ssh_login_timeout => "10000", :ssh_user => "vagrant", :ssh_password => "vagrant", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd => "/sbin/halt -h -p",
  :postinstall_files => [ "postinstall.sh"], :postinstall_timeout => 10000
})
