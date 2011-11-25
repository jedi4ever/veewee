Veewee::Session.declare({
<<<<<<< HEAD
  :cpu_count => '1', :memory_size=> '384', 
  :disk_size => '10140', :disk_format => 'VDI', :hostiocache => 'off',
=======
  :cpu_count => '1', 
  :memory_size=> '384', 
  :disk_size => '10140', 
  :disk_format => 'VDI', 
  :hostiocache => 'off',
>>>>>>> 34932ec8fc8d87efb3846e336400a726f381252e
  :os_type_id => 'Ubuntu_64',
  :iso_file => "ubuntu-11.10-server-amd64.iso",
  :iso_src => "http://releases.ubuntu.com/11.10/ubuntu-11.10-server-amd64.iso",
  :iso_md5 => "f8a0112b7cb5dcd6d564dbe59f18c35f",
  :iso_download_timeout => "1000",
<<<<<<< HEAD
  :boot_wait => "10", :boot_cmd_sequence => [
=======
  :boot_wait => "10", 
  :boot_cmd_sequence => [
>>>>>>> 34932ec8fc8d87efb3846e336400a726f381252e
    '<Esc><Esc><Enter>',
    '/install/vmlinuz noapic preseed/url=http://%IP%:%PORT%/preseed.cfg ',
    'debian-installer=en_US auto locale=en_US kbd-chooser/method=us ',
    'hostname=%NAME% ',
    'fb=false debconf/frontend=noninteractive ',
    'keyboard-configuration/layout=USA keyboard-configuration/variant=USA console-setup/ask_detect=false ',
    'initrd=/install/initrd.gz -- <Enter>'
  ],
<<<<<<< HEAD
  :kickstart_port => "7122", :kickstart_timeout => "10000", :kickstart_file => "preseed.cfg",
  :ssh_login_timeout => "10000", :ssh_user => "vagrant", :ssh_password => "vagrant", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd => "shutdown -P now",
  :postinstall_files => [ "postinstall.sh"], :postinstall_timeout => "10000"
=======
  :kickstart_port => "7122", 
  :kickstart_timeout => "10000", 
  :kickstart_file => "preseed.cfg",
  :ssh_login_timeout => "10000", 
  :ssh_user => "vagrant", 
  :ssh_password => "vagrant", 
  :ssh_key => "",
  :ssh_host_port => "7222", 
  :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd => "shutdown -P now",
  :postinstall_files => [ "postinstall.sh"], 
  :postinstall_timeout => "10000"
>>>>>>> 34932ec8fc8d87efb3846e336400a726f381252e
})
