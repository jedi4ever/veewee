# This will fail with a checksum error.  Just unzip the downloaded ISO.zip in
# the iso directory and rerun.  This script essentially makes a Nexenta
# appliance a general purpose system Nexenta which is counter to the goals of
# NexentaStor...  But, hackers will hack... its the way of things.

Veewee::Definition.declare({
  :cpu_count => '2',
  :memory_size=> '1024',
  :disk_size => '10000',
  :disk_format => 'VDI',
  :hostiocache => 'off',
  :hwvirtext => 'on',
  :os_type_id => 'OpenSolaris_64',
  :iso_file => "NexentaStor-Community-3.1.2.iso",
  :iso_src => "http://downloads.nexenta.com/cdn/NexentaStor-Community-3.1.2.iso.zip",
  :iso_download_instructions => "You'll need to manually unzip the ISO file\n",
  :iso_md5 => "260270ba7162298c6f597eed78009079",
  :iso_download_timeout => 1000,
  :boot_wait => "10",
  :boot_cmd_sequence => [ 
    '<Enter>',                # Install NexentaStor Community Edition
    '<Wait>'*5'<Enter>',      # I agree
    '<Enter>',                # Okay
    '<Wait>'*5'<Enter>',      # Select Disk Found
    '<Enter>',                # Yes, kill the disk
    '<Wait>'*400'<Enter>',    # Main install and acknowledge a reboot
    '<Wait>'*200'<Enter>',    # Agree to license
    '<Wait>'*30'XXXX<Enter>', # Replace XXXX with your license!!!
    'n<Enter>',               # don't reconfig
    '<Enter>',                # talk http
    '<Enter>',                # port 2000 is fine
    '<Wait>'*400,             # Long config part
    'root<Enter>',            # root login
    'nexenta<Enter>',         # nexenta is the password
    'option expert_mode = 1<Enter>', # unlocking the ability to go to bash
    '!bash<Enter>y',           # you are now at the shell
    'useradd -g vagrant -G rvm -c "Added by VeeWee" -b /var  -m vagrant<Enter>',
    'apt-get install sudo<Enter>',
    'apt-get update<Enter>',
    'echo "vagrant ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers<Enter>',
    'apt-get install gcc -o APT::Install-Suggests=true<Enter>',
    'apt-get install ca-certificates<Enter>',
    'passwd vagrant<Enter>',  # set the vagrant passwd
    'vagrant<Enter>',
    'vagrant<Enter>'          # Should be good to postinstall now
    ],
  :ssh_login_timeout => "10000",
  :ssh_user => "vagrant",
  :ssh_password => "vagrant",
  :ssh_key => "",
  :ssh_host_port => "7222",
  :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S bash ./%f",
  :shutdown_cmd => "/usr/sbin/halt",
  :postinstall_files => [ "postinstall.sh"],
  :postinstall_timeout => 10000
})

