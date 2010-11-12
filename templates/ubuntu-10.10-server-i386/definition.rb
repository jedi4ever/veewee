Veewee::Session.declare( {
  :cpu_count => '1', :memory_size=> '256', 
  :disk_size => '10140', :disk_format => 'VDI',:disk_size => '10240' ,
  :os_type_id => 'Ubuntu',
  :iso_file => "ubuntu-10.10-server-i386.iso", :iso_src => "", :iso_md5 => "", :iso_download_timeout => 1000,
  :boot_wait => "10",:boot_cmd_sequence => [ 
                 '<Esc><Esc><Enter>',
    		          '/install/vmlinuz noapic preseed/url=http://%IP%:%PORT%/preseed.cfg debian-installer=en_US auto locale=en_US kbd-chooser/method=us ',
   				      'hostname=%NAME% ',
    		          'fb=false debconf/frontend=noninteractive ',
   		          'console-setup/ask_detect=false console-setup/modelcode=pc105 console-setup/layoutcode=us ',
    		          'initrd=/install/initrd.gz -- <Enter>' 
    ],
  :kickstart_port => "7122", :kickstart_timeout => 10000,:kickstart_file => "preseed.cfg",
  :ssh_login_timeout => "100",:ssh_user => "vagrant", :ssh_password => "vagrant",:ssh_key => "",
  :ssh_host_port => "2222", :ssh_guest_port => "22",
  :postinstall_files => [ "postinstall.sh"],:postinstall_timeout => 10000
   }
)
##		isosrc => "http://releases.ubuntu.com/10.10/ubuntu-10.10-server-i386.iso",
#		isosrc => "file:///Users/patrick/vagrantbox/dists/ubuntu-10.10-server-i386.iso",
#		isodst => "/Users/patrick/vagrantbox/downloads/ubuntu-10.10-server-i386.iso",
#		isomd5 => "ce1cee108de737d7492e37069eed538e",
#		vostype => "Ubuntu",
#		bootcmd => [ '<Esc><Esc><Enter>',
#		          '/install/vmlinuz noapic preseed/url=http://192.168.2.30:7125/preseed.cfg debian-installer=en_US auto locale=en_US kbd-chooser/method=us ',
#				  'hostname=ubuntu ',
#		          'fb=false debconf/frontend=noninteractive ',
#		          'console-setup/ask_detect=false console-setup/modelcode=pc105 console-setup/layoutcode=us ',
#		          'initrd=/install/initrd.gz -- <Enter>' ],
#		bootwait => "30",
#})
