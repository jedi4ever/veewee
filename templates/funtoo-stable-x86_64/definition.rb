password = 'vagrant'
builddate = '20131226'
iso = "install-amd64-minimal-#{builddate}.iso"

Veewee::Session.declare({
  :hostiocache => 'off',
  :cpu_count => '1',
  :memory_size=> '384',
  :disk_size => '40560', # 40 GB
  :disk_format => 'VDI',
  :os_type_id => 'Gentoo_64', # for 32bit, change to 'Gentoo'
  :iso_file => iso,
  :iso_src => "http://mirror.switch.ch/ftp/mirror/gentoo/releases/amd64/autobuilds/#{builddate}/#{iso}",
  :iso_sha512 => "4a19a59c5fa5f2d3a8fd31cde2379abafcb0e3c720884471e1dc0b2557fda3328198dea728d8c6f792a0ccf3e56f1e4dfadbdcb41e38bb675b8de0bea36ab0a9",
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
        'ifconfig -a <Enter><Wait><Wait>',
        'passwd<Enter><Wait><Wait>',
        password + '<Enter><Wait>',
        password + '<Enter><Wait><Wait>',
        '/etc/init.d/sshd start<Enter><Wait><Wait>'
    ],
  :ssh_login_timeout => "10000",
  :ssh_user => "root",
  :ssh_password => password,
  :ssh_key => "",
  :ssh_host_port => "7222",
  :ssh_guest_port => "22",
  :sudo_cmd => "cat '%f'|su -",
  :shutdown_cmd => "init 0",
  :postinstall_files => ["postinstall.sh"],
  :postinstall_timeout => "15000"
})
