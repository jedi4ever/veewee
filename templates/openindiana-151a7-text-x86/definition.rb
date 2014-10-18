Veewee::Definition.declare({
  :cpu_count => '1', :memory_size=> '768',
  #Disk size needs to be 12Gig +
  :disk_size => '15140', :disk_format => 'VDI', :hostiocache => 'on', :hwvirtex => 'on',
  :os_type_id => 'OpenSolaris',
  :iso_file => "oi-dev-151a7-text-x86.iso",
  :iso_src => "http://dlc.openindiana.org/isos/151a7/oi-dev-151a7-text-x86.iso",
  :iso_md5 => "d54c8333d577c720cd9ba972253a59a3",
  :iso_download_timeout => 1000,
  :boot_wait => "70", :boot_cmd_sequence => [
    '47<Enter>',
    '<Wait>'*2,
    '7<Enter>',
    '<Wait>'*80,
    '<Enter>',
    '<Wait>'*60,
    '<Esc>2','<Wait>'*2,
    '<Esc>2','<Wait>'*2,
    '<Esc>2','<Wait>'*2,
    # Name and Network
    '<Down><Esc>2','<Wait>'*2,
    # Time Zone = GMT
    '<Esc>2','<Wait>'*2,
    # Date
    '<Esc>2','<Wait>'*2,
    # Password
    'vagrant<Down>'*2,
    'Vagrant<Down>',
    'vagrant<Down>'*3,
    '<Esc>2','<Wait>'*2,
    # Yes Install.. 
    '<Esc>2','<Wait>'*2,
    '<Wait>'*200,
    # Reboot
    '<Esc>8',
    '<Wait>'*600,
    # login as vagrant
    'vagrant<Enter><Wait>'*2,
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

