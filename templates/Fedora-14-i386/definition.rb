Veewee::Definition.declare({
  :cpu_count => '1', :memory_size=> '384',
  :disk_size => '10140', :disk_format => 'VDI', :hostiocache => 'off', :hwvirtex => 'on',
  :os_type_id => 'Fedora',
  :iso_file => "Fedora-14-i386-DVD.iso",
  :iso_src => "http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/14/Fedora/i386/iso/Fedora-14-i386-DVD.iso",
  :iso_md5 => "1cc67641506d2f931d669b8d3528dded",
  :iso_download_timeout => 1000,
  :boot_wait => "10", :boot_cmd_sequence => [ '<Tab> linux text ks=http://%IP%:%PORT%/ks.cfg<Enter><Enter>' ],
  :kickstart_port => "7122", :kickstart_timeout => 300, :kickstart_file => "ks.cfg",
  :ssh_login_timeout => "10000", :ssh_user => "vagrant", :ssh_password => "vagrant", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd => "/sbin/halt -h -p",
  :postinstall_files => [ "postinstall.sh"], :postinstall_timeout => 10000
})
