# obviously this is using the "alternate" ISO, not the "server" ISO, but that
# is only because it hasn't been released yet.
Veewee::Session.declare({
  :cpu_count => '2',
  :memory_size=> '1500',
  :disk_size => '10140',
  :disk_format => 'VDI',
  :hostiocache => 'off',
  :os_type_id => 'Ubuntu_64',
# :iso_file => "precise-alternate-amd64-#{Time.now.strftime('%Y-%m-%d')}.iso",
  :iso_file => "precise-alternate-amd64.iso",
  :iso_src => "http://cdimage.ubuntu.com/ubuntu-server/daily/current/precise-server-amd64.iso",
  :iso_md5 => "`curl -s http://cdimage.ubuntu.com/ubuntu-server/daily/current/MD5SUMS -o - | awk '{if ( $2 == \"*precise-server-amd64.iso\") print $1 }'`",
  :iso_download_timeout => "1000",
  :boot_wait => "4",
  :boot_cmd_sequence => [
    '<Esc><Esc><Enter>',
    '/install/vmlinuz noapic preseed/url=http://%IP%:%PORT%/preseed.cfg ',
    'debian-installer=en_US auto locale=en_US kbd-chooser/method=us ',
    'hostname=%NAME% ',
    'fb=false debconf/frontend=noninteractive ',
    'keyboard-configuration/layout=USA keyboard-configuration/variant=USA console-setup/ask_detect=false ',
    'initrd=/install/initrd.gz -- <Enter>'
],
  :kickstart_port => "7122",
  :kickstart_timeout => "10000",
  :kickstart_file => "preseed.cfg",
  :ssh_login_timeout => "10000",
  :ssh_user => "vagrant",
  :ssh_password => "vagrant",
  :ssh_key => "",
  :ssh_host_port => "7222",
  :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd => "shutdown -P now",
  :postinstall_files => [ "postinstall.sh"],
  :postinstall_timeout => "10000"
})
