Veewee::Definition.declare({
  :cpu_count => '1', :memory_size=> '384', 
  :disk_size => '10140', :disk_format => 'VDI', :hostiocache => 'off',
  :os_type_id => 'OpenSUSE',
  :iso_file => "openSUSE-11.4-DVD-i586.iso",
  :iso_src => "http://download.opensuse.org/distribution/11.4/iso/openSUSE-11.4-DVD-i586.iso",
  #:iso_src => "http://ftp.belnet.be/mirror/ftp.opensuse.org/distribution/11.4/iso/openSUSE-11.4-DVD-i586.iso",
  :iso_md5 => "5f6d6d67c3e256b2513311f4ed650515",
  :iso_download_timeout => "1000",
  :boot_wait => "10", :boot_cmd_sequence => [
    '<Esc><Enter>',
    'linux',
    #'/install/vmlinuz noapic preseed/url=http://%IP%:%PORT%/preseed.cfg ',
    ' netdevice=eth0',
    ' netsetup=dhcp',
    ' instmode=dvd',
    #' install=file://mnt/suse',
    ' textmode=1 autoyast=http://%IP%:%PORT%/autoinst.xml',
    #'hostname=%NAME% ',
    #'initrd=/install/initrd.gz -- <Enter>'
    '<Enter>'
   ],
  :kickstart_port => "7122", :kickstart_timeout => "10000", 
  #We need this twice, as it is read twice
  :kickstart_file => ["autoinst.xml","autoinst.xml"],
  :ssh_login_timeout => "10000", :ssh_user => "vagrant", :ssh_password => "vagrant", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd => "shutdown -P now",
  :postinstall_files => [ "postinstall.sh"], :postinstall_timeout => "10000"
})
