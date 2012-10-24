password = 'vagrant'

Veewee::Session.declare({
# READ: http://www.virtualbox.org/manual/ch08.html#vboxmanage - some nice options below...
# ...disabled for greater compatibility - we shouldn't depend on this
#  :virtualbox => { :vm_options => [{
#    'firmware' => 'efi',
#    'ioapic' => 'on',
#    'hpet' => 'on',
#    'pae' => 'on'
#  }] },
  :hostiocache => 'off',
  :cpu_count => '1',
  :memory_size=> '384',
  :disk_size => '10140',
  :disk_format => 'VDI',
#  :os_type_id => 'Gentoo',    # change for 32 bit
  :os_type_id => 'Gentoo_64',
  :iso_file => "systemrescuecd-x86-3.0.0.iso",
  :iso_src => "http://freefr.dl.sourceforge.net/project/systemrescuecd/sysresccd-x86/3.0.0/systemrescuecd-x86-3.0.0.iso",
  :iso_md5 => "6bb6241af752b1d6dab6ae9e6e3e770e",
  :iso_download_timeout => "1000",
  :boot_wait => "4",
  :boot_cmd_sequence => [
        '<Wait>'*1,
        '<Enter>',
        '<Wait>'*9,
        '<Enter>',
        '<Wait>'*12,
        '<Enter><Wait>',      # just in case we are out of sync
        'net-setup eth0<Enter><Wait><Enter>2<Enter>1<Enter><Wait><Wait>',
        'passwd<Enter><Wait><Wait>',
        password + '<Enter><Wait>',
        password + '<Enter><Wait><Wait>'
    ],
  :ssh_login_timeout => "10000",
  :ssh_user => "root",
  :ssh_password => password,
  :ssh_key => "",
  :ssh_host_port => "7222",
  :ssh_guest_port => "22",
  :sudo_cmd => "cat '%f'|su -",
  :shutdown_cmd => "shutdown -p now",
  :postinstall_files => ["postinstall.sh"],
  :postinstall_timeout => "15000"
})
