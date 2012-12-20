Veewee::Session.declare({
  # Minimum RAM requirement for installation is 512MB.
  :cpu_count => '1', :memory_size=> '512',
  :disk_size => '10140', :disk_format => 'VDI', :hostiocache => 'off', :hwvirtext => 'on',
  :os_type_id => 'Fedora',
  :iso_file => "Fedora-18-Beta-i386-DVD.iso",
  :iso_src => "http://download.fedoraproject.org/pub/fedora/linux/releases/test/18-Beta/Fedora/i386/iso/Fedora-18-Beta-i386-DVD.iso",
  :iso_md5 => "fe79303aec5231df82ebe4a30e0dc83c",
  :iso_download_timeout => 1000,
  :boot_wait => "10", :boot_cmd_sequence => [ '<Tab> linux text biosdevname=0 ks=http://%IP%:%PORT%/ks.cfg<Enter><Enter>' ],
  :kickstart_port => "7122", :kickstart_timeout => 10000, :kickstart_file => "ks.cfg",
  :ssh_login_timeout => "10000", :ssh_user => "vagrant", :ssh_password => "vagrant", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd => "/sbin/halt -h -p",
  :postinstall_files => [ "postinstall.sh" ], :postinstall_timeout => 10000
})
