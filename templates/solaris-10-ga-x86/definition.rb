Veewee::Definition.declare({
  :cpu_count => '1', :memory_size=> '768',
  #Disk size needs to be 12Gig +
  :disk_size => '65140', :disk_format => 'VDI', :hostiocache => 'off',
  :virtualbox => { :vm_options => [ "hwvirtex" => "on" ] },
  :os_type_id => 'OpenSolaris_64',
  :iso_file => "sol-10-u11-ga-x86-dvd.iso",
  :iso_src => "",
  :iso_download_instructions => "- You need to download this manually as there is no automated way to do it\n"+
    "http://www.oracle.com/technetwork/server-storage/solaris10/downloads/index.html\n"+
    "\n"+
    "- The version tested is 1/13\n"+
    "- For other version: changed the iso filename+checksum\n",
  :iso_md5 => "aae1452bb3d56baa3dcb8866ce7e4a08",
  :iso_download_timeout => 1000,
  :boot_wait => "10", :boot_cmd_sequence => [
    'e',
    'e',
    '<Backspace>'*22,
    '- nowin install -B install_media=cdrom<Enter>',
    # It seems there is no need to have a correct checksum for 'rules.ok'
    # If it is suddenly needed, you will need to go into interactive mode or use a running Solaris system to validate
    #'- install ask -B install_media=cdrom<Enter>',
    'b',
    ],
  :floppy_files => [ "jumpstart/sysidcfg", "jumpstart/rules", "jumpstart/rules.ok",
    "jumpstart/begin", "jumpstart/profile", "jumpstart/finish" ],
  :ssh_login_timeout => "10000", :ssh_user => "vagrant", :ssh_password => "vagrant", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "pfexec bash -l %f",
  :shutdown_cmd => "/usr/sbin/poweroff",
  :postinstall_files => [
    "postinstall.sh",
    "puppet.sh",
    "chef.sh",
    "update-terminfo.sh",
    "cleanup.sh"
  ],
  :postinstall_timeout => 10000
})
