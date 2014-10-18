Veewee::Session.declare({
  :cpu_count => '1',
  :memory_size=> '480',
  :disk_size => '10140',
  :disk_format => 'VDI',
  :hostiocache => 'off',
  :os_type_id => 'RedHat',
  :iso_file => "CentOS-6.4-i386-minimal.iso",
  :iso_src => "http://mirror.symnds.com/distributions/CentOS-vault/6.4/isos/i386/CentOS-6.4-i386-minimal.iso",
  :iso_md5 => "6b5c727fa76fcce7c9ab6213ad3df75a",
  :iso_download_timeout => 1000,
  :boot_wait => "10",
  :boot_cmd_sequence => [
    '<Tab> text ks=http://%IP%:%PORT%/ks.cfg<Enter>'
  ],
  :kickstart_port => "7122",
  :kickstart_timeout => 300,
  :kickstart_file => "ks.cfg",
  :ssh_login_timeout => "10000",
  :ssh_user => "veewee",
  :ssh_password => "veewee",
  :ssh_key => "",
  :ssh_host_port => "7222",
  :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd => "/sbin/halt -h -p",
  :postinstall_files => [
    "base.sh",
    "chef.sh",
    "puppet.sh",
    "vagrant.sh",
    #"vmfusion.sh",
    "virtualbox.sh",
    "cleanup.sh",
    "zerodisk.sh"
  ],
  :postinstall_timeout => 10000
})
