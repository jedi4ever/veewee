Veewee::Session.declare({
  :cpu_count => '1', :memory_size=> '384',
  :disk_size => '81920', :disk_format => 'VDI', :hostiocache => 'off', :ioapic => 'on', :pae => 'on',
  :os_type_id => 'RedHat',
  :iso_file => "SL.57.091211.CD.i386.disc1.iso",
  :iso_src => "http://ftp.heanet.ie/pub/rsync.scientificlinux.org/57/iso/i386/cd/SL.57.091211.CD.i386.disc1.iso",
  :iso_md5 => "e0a2bfb50febc493204f30e314637b10",
  :iso_download_timeout => 1000,
  :boot_wait => "10", :boot_cmd_sequence => [ 'linux text ks=http://%IP%:%PORT%/ks.cfg<Enter>' ],
  :kickstart_port => "7122", :kickstart_timeout => 300, :kickstart_file => "ks.cfg",
  :ssh_login_timeout => "10000", :ssh_user => "vagrant", :ssh_password => "vagrant", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd => "/sbin/halt -h -p",
  :postinstall_files => [ "postinstall.sh"], :postinstall_timeout => 10000
})
