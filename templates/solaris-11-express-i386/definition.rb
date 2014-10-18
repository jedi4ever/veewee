Veewee::Definition.declare({
  :cpu_count => '1', :memory_size=> '768',
  #Disk size needs to be 12Gig +
  :disk_size => '15140', :disk_format => 'VDI', :hostiocache => 'off', :hwvirtex => 'on',
  :os_type_id => 'OpenSolaris',
  :iso_file => "sol-11-exp-201011-ai-x86.iso",
  :iso_src => "",
  :iso_download_instructions => "- You need to download this manually as there is no automated way to do it\n"+
    "http://www.oracle.com/technetwork/server-storage/solaris11/downloads/index.html\n"+
    "\n"+
    "- The version tested is 2010.11\n"+
    "- For other version: changed the iso filename+checksum\n",
  :iso_md5 => "36527d4d49a645ef6f6d2677c8e0118c",
  :iso_download_timeout => 1000,
  :boot_wait => "10", :boot_cmd_sequence => [ 
    'e',
    'e',
    '<Backspace>'*22,
    'false',
    #',aimanifest=prompt',
    #',aimanifest=http://%IP%:%PORT%/default.xml',
    '<Enter>',
    'b',
    '<Wait>'*75,

    # login as root
    'root<Enter><Wait>',
    'solaris<Enter><Wait>',

    # Background check when install is complete, add vagrant to the sudo 
    'while (true); do sleep 5; test -f /a/etc/sudoers  && grep -v "vagrant" "/a/etc/sudoers" 2> /dev/null',
    ' && echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /a/etc/sudoers && break ; done &<Enter>',

    # Background check to see if install has finished and reboot
    '<Enter>while (true); do grep "You may wish to reboot" "/tmp/install_log" 2> /dev/null',
    ' && reboot; sleep 10; done &<Enter>',

    # Wait for 5 seconds, so the webserver will be up
    'sleep 5; curl http://%IP%:%PORT%/default.xml -o default.xml;',
    'cp default.xml /tmp/ai_combined_manifest.xml;',

    # Start the installer
    'svcadm enable svc:/application/auto-installer:default;',

    # Wait for the installer to launch and display the logfile
    'sleep 3; tail -f /tmp/install_log<Enter>'

    ],
  :kickstart_port => "7122", :kickstart_timeout => 300, :kickstart_file => "default.xml",
  :ssh_login_timeout => "10000", :ssh_user => "vagrant", :ssh_password => "vagrant", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S bash ./%f",
  :shutdown_cmd => "/usr/sbin/halt",
  :postinstall_files => [ "postinstall.sh"], :postinstall_timeout => 10000
})

# Notes:
# http://dlc.sun.com/osol/docs/content/dev/AIinstall/aimanifest.html
# http://download.oracle.com/docs/cd/E19963-01/html/820-6566/media-ai.html#gklco
# default.xml
# /.cdrom/auto_install/default.xml
# /usr/share/auto_install/default.xml

#tail -f /tmp/install.log

