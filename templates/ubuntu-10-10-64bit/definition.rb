Veewee::Session.declare( {
   :cpu => "1",
   :memory => "384",
   :disk_size => "10240",
   :boot_cmd_sequence => [ 
                  '<Esc><Esc><Enter>',
     		          '/install/vmlinuz noapic preseed/url=http://%IP%:%PORT%/preseed.cfg debian-installer=en_US auto locale=en_US kbd-chooser/method=us ',
    				      'hostname=%NAME% ',
     		          'fb=false debconf/frontend=noninteractive ',
    		          'console-setup/ask_detect=false console-setup/modelcode=pc105 console-setup/layoutcode=us ',
     		          'initrd=/install/initrd.gz -- <Enter>' 
     ]
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
