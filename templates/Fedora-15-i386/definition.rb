Veewee::Session.declare({
  # Minimum RAM requirement for installation is 640MB.
  :cpu_count => '1', :memory_size=> '640',
  :disk_size => '10140', :disk_format => 'VDI', :hostiocache => 'off', :hwvirtext => 'on',
  :os_type_id => 'Fedora',
  :iso_file => "Fedora-15-i386-DVD.iso",
  :iso_src => "http://download.fedoraproject.org/pub/fedora/linux/releases/15/Fedora/i386/iso/Fedora-15-i386-DVD.iso",
  :iso_md5 => "eea96f0d780687a73fdbc78137b38584",
  :iso_download_timeout => 1000,
  :boot_wait => "10", :boot_cmd_sequence => [ '<Tab> linux text ks=http://%IP%:%PORT%/ks.cfg<Enter><Enter>' ],
  :kickstart_port => "7122", :kickstart_timeout => 10000, :kickstart_file => "ks.cfg",
  :ssh_login_timeout => "100", :ssh_user => "vagrant", :ssh_password => "vagrant", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd => "/sbin/halt -h -p",
  :postinstall_files => [ "postinstall.sh"], :postinstall_timeout => 10000
})
