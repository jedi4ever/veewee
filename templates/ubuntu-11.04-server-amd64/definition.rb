Veewee::Definition.declare({
  :cpu_count => '1', :memory_size=> '384', 
  :disk_size => '10140', :disk_format => 'VDI', :hostiocache => 'off',
  :os_type_id => 'Ubuntu_64',
  :iso_file => "ubuntu-11.04-server-amd64.iso",
  :iso_src => "http://old-releases.ubuntu.com/releases/11.04/ubuntu-11.04-server-amd64.iso",
  :iso_md5 => "355ca2417522cb4a77e0295bf45c5cd5",
  :iso_download_timeout => "1000",
  :boot_wait => "10", :boot_cmd_sequence => [
    '<Esc><Esc><Enter>',
    '/install/vmlinuz ',
    'initrd=/install/initrd.gz ',
    'noapic ',
    'fb=false ', # don't bother using a framebuffer
    'locale=en_US ', # Start installer in English
    'console-setup/ask_detect=false ', # Don't ask to detect keyboard
    'keyboard-configuration/layout=USA ', # set it to US qwerty
    'keyboard-configuration/variant=USA ',
    'hostname=%NAME% ', # Set the hostname
    'preseed/url=http://%IP%:%PORT%/preseed.cfg ', # Fetch the rest from here
    'auto ',
    'debconf/frontend=noninteractive ',
    'debian-installer=en_US ',
    'kbd-chooser/method=us ',
    '-- <Enter>'
  ],
  :kickstart_port => "7122", :kickstart_timeout => "300", :kickstart_file => "preseed.cfg",
  :ssh_login_timeout => "10000", :ssh_user => "vagrant", :ssh_password => "vagrant", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd => "shutdown -P now",
  :postinstall_files => [
                          "timestamp.sh",
                          "apt-upgrade.sh",
                          "sudo.sh",
                          "nfs-client.sh",
                          "ruby.sh",
                          "chef.sh",
                          "puppet.sh",
                          "ssh-keys.sh",
                          "vbox_additions.sh",
                          "network-cleanup.sh",
                          "remove-build-essentials.sh",
                          "zero-disk.sh",
                        ],
  :postinstall_timeout => "10000"
})
