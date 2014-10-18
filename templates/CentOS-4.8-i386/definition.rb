Veewee::Definition.declare({
  :cpu_count => '1', :memory_size=> '384',
  :disk_size => '10140', :disk_format => 'VDI',:hostiocache => 'off',:ioapic => 'on', :pae => 'on',
  :os_type_id => 'RedHat',
  :iso_file => "CentOS-4.8-i386-bin-DVD.iso", :iso_src => "", :iso_md5 => "", :iso_download_timeout => 1000,
  :iso_download_instructions => "This iso is no more available, for instructions see http://vault.centos.org/4.8/isos/i386/",
  :boot_wait => "10", :boot_cmd_sequence => [ 'linux text ks=http://%IP%:%PORT%/ks.cfg<Enter>' ],
  :kickstart_port => "7122", :kickstart_timeout => 300, :kickstart_file => "ks.cfg",
  :ssh_login_timeout => "10000", :ssh_user => "vagrant", :ssh_password => "vagrant", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd => "/sbin/halt -h -p",
  :postinstall_files => [ "postinstall.sh"], :postinstall_timeout => 10000
})
