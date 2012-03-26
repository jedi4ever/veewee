# This will fail with a checksum error.  Just unzip the downloaded ISO.zip in
# the iso directory and rerun.  This script essentially makes a Nexenta
# appliance a general purpose system Nexenta which is counter to the goals of
# NexentaStor...  But, hackers will hack... its the way of things.
Veewee::Session.declare({
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
  :boot_wait => "15",
  :boot_cmd_sequence => [ 
    '<Enter>',                    # Install NexentaStor Community Edition
    '<Wait>'*55,'<Enter>',        # I agree
    '<Wait>'*7,'<Enter>',         # Okay
    '<Wait>'*25,'<Enter>',        # Select Disk Found
    '<Wait>'*3,'<Enter>',         # Yes, kill the disk
    '<Wait>'*660,'<Enter>',       # Main install and acknowledge a reboot
    '<Wait>'*100,'<Enter>',       # Agree to license
    '<Wait>'*30,'XXXX<Enter>',    # Replace XXXX with your license!!!
    '<Wait><Wait>n<Enter>',       # don't reconfig
    '<Wait><Wait><Enter>',        # talk http
    '<Wait><Wait><Enter>',        # port 2000 is fine
    '<Wait>'*600,                 # Long config part
    '<Wait><Wait>root<Enter>',    # root login
    '<Wait><Wait>nexenta<Enter>', # nexenta is the password
    '<Wait><Wait>option expert_mode = 1<Enter>', # unlocking the ability to go to bash
    '<Wait><Wait>!bash<Enter>y',           # you are now at the shell
    '<Wait><Wait>useradd -g vagrant -G rvm -c "Added by VeeWee" -b /var  -m vagrant<Enter>',
    '<Wait><Wait>apt-get install sudo<Enter>',
    '<Wait><Wait>apt-get update<Enter>',
    '<Wait><Wait>echo "vagrant ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers<Enter>',
    '<Wait><Wait>apt-get install gcc -o APT::Install-Suggests=true<Enter>',
    '<Wait><Wait>apt-get install ca-certificates<Enter>',
    '<Wait><Wait>passwd vagrant<Enter>',  # set the vagrant passwd
    '<Wait><Wait>vagrant<Enter>',
    '<Wait><Wait>vagrant<Enter>',         # Should be good to postinstall now
    '<Wait><Wait>'
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

