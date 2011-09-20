Veewee::Session.declare({
  :os_type_id => 'OpenSUSE_64', :cpu_count => '1', :memory_size=> '512',
  :disk_size => '20480', :disk_format => 'VDI', :hostiocache => 'off',
  :iso_file => "openSUSE-11.4-NET-x86_64.iso",
  :iso_src => "http://download.opensuse.org/distribution/11.4/iso/openSUSE-11.4-NET-x86_64.iso",
  #:iso_src => "http://ftp.belnet.be/mirror/ftp.opensuse.org/distribution/11.4/iso/openSUSE-11.4-NET-x86_64.iso",
  :iso_md5 => "bb0dc0124d5d2e3292ec96717132b136",
  :iso_download_timeout => "1000",
  :boot_wait => "10", :boot_cmd_sequence => [
    '<Esc><Enter>',
    'linux netdevice=eth0 netsetup=dhcp',
    ' install=http://download.opensuse.org/distribution/11.4/repo/oss/ insecure=1',
    ' lang=en_US autoyast=http://%IP%:%PORT%/autoinst_en.xml',
    # disable prev line and enable next line to install with german settings
    #' lang=de_DE autoyast=http://%IP%:%PORT%/autoinst_de.xml',
    ' textmode=1',
    '<Enter>'
   ],
  :kickstart_port => "7122", :kickstart_timeout => "10000",
  :kickstart_file => ["autoinst_en.xml", "autoinst_en.xml"],
  # disable prev line and enable next line to install with german settings
  #:kickstart_file => ["autoinst_de.xml", "autoinst_de.xml"],
  :ssh_login_timeout => "10000", :ssh_user => "vagrant", :ssh_password => "vagrant", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd => "shutdown -P now",
  :postinstall_files => ["postinstall.sh"], :postinstall_timeout => "10000"
})
