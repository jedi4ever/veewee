Veewee::Definition.declare({
  :cpu_count => '1', :memory_size=> '512',
  :disk_size => '10140', :disk_format => 'VDI', :hostiocache => 'off',
  :os_type_id => 'Linux26',
  :iso_file => "systemrescuecd-x86-2.3.1.iso",
  :iso_src => "http://downloads.sourceforge.net/project/systemrescuecd/sysresccd-x86/2.3.1/systemrescuecd-x86-2.3.1.iso",
  :iso_md5 => "8813aa38506f6e6be1c02e871eb898ca",
  #:iso_file => "systemrescuecd-x86-2.0.0.iso",
  #:iso_src => "http://downloads.sourceforge.net/project/systemrescuecd/sysresccd-x86/2.0.0/systemrescuecd-x86-2.0.0.iso",
  #:iso_md5 => "51012e0bb943cff6367e5cea3a61cdbe",
  :iso_download_timeout => "1000",
  :boot_wait => "10", :boot_cmd_sequence => [
    '<Tab> raid=noautodetect setkmap=us dodhcp=eth0 fastboot dhcphostname=%NAME% rootpass=vagrant ar_source=http://%IP%:%PORT%/ autoruns=0 ar_nowait dns=127.0.0.1 nomodeset nodetect nodmraid nomadm edd=off quiet nosata nosound nosmp nohotplug acpi=off noresume load=eth1000 nonet noload=ipv6,floppy,md,raid10,raid456,raid1,raid0,multipath,linear,i2c_piix4,i2c_core,udev scandelay=0 nousb<Enter>'
  ],
  :kickstart_port => "7122", :kickstart_timeout => "10000",
  :kickstart_file => "autorun0.erb",

  :ssh_login_timeout => "10000", :ssh_user => "root", :ssh_password => "vagrant", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "sh '%f'",
  :shutdown_cmd => "shutdown -h -H now",
  :postinstall_files => ["_disabled_postinstall.sh", "enabled_postinstall.sh" ],
  :postinstall_timeout => "10000"
})
