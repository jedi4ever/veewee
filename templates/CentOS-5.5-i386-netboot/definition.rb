Veewee::Session.declare({
  :cpu_count => '1', :memory_size=> '384',
  :disk_size => '10140', :disk_format => 'VDI', :hostiocache => 'off', :ioapic => 'on', :pae => 'on',
  :os_type_id => 'RedHat',
  :iso_file => "CentOS-5.5-i386-netinstall.iso",
  :iso_src => "http://mirror.symnds.com/distributions/CentOS-vault/5.5/isos/i386/CentOS-5.5-i386-netinstall.iso",
  :iso_md5 => "0172883a3039772165db073693debae5",
  :iso_download_timeout => 1000,
  :boot_wait => "10", :boot_cmd_sequence => [ 'linux text ks=http://%IP%:%PORT%/ks.cfg<Enter>' ],
  :kickstart_port => "7122", :kickstart_timeout => 300, :kickstart_file => "ks.cfg",
  :ssh_login_timeout => "600", :ssh_user => "vagrant", :ssh_password => "vagrant", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd => "/sbin/halt -h -p",
  :postinstall_files => [ "postinstall.sh"], :postinstall_timeout => 10000
})
