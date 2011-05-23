Veewee::Session.declare({
  :cpu_count => '1', :memory_size=> '384', 
  :disk_size => '10140', :disk_format => 'VDI', :hostiocache => 'off',
  :os_type_id => 'Windows2008_64',
  :iso_file => "7601.17514.101119-1850_x64fre_server_eval_en-us-GRMSXEVAL_EN_DVD.iso",
  :iso_src => "",
  :iso_md5 => "",
  :floppy_files => ["Autounattend.xml","setup.exe","cygwin-sshd.bat"],
  :iso_download_timeout => "1000",
  :boot_wait => "10", :boot_cmd_sequence => [
  ],
  :kickstart_port => "7122", :kickstart_timeout => "10000", :kickstart_file => "preseed.cfg",
  :ssh_login_timeout => "10000", :ssh_user => "vagrant", :ssh_password => "vagrant", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd => "shutdown -P now",
  :postinstall_files => [], :postinstall_timeout => "10000"
})
