# sudo acpid and wget are not included in the minimal DVD ISO. To fix
# this, use the *bin* ISO or run "yum install ..." in %post
Veewee::Session.declare({
  :cpu_count => '1',
  :memory_size=> '480',
  :disk_size => '10140',
  :disk_format => 'VDI',
  :hostiocache => 'on',
  :os_type_id => 'RedHat',
  :virtualbox => { :vm_options => [
                                   'hwvirtex' => 'off',
                                   'nestedpaging' => 'off',
                                   'natdnshostresolver1' => 'on'
                                  ]
                          },
  :iso_file => "CentOS-6.3-i386-minimal.iso",
  :iso_src => "http://mirror.symnds.com/distributions/CentOS-vault/6.3/isos/i386/CentOS-6.3-i386-minimal.iso",
  :iso_md5 => "081ce8ba3e9f761a35d47f1c345562c1",
  :iso_download_timeout => 1000,
  :boot_wait => "10",
  :boot_cmd_sequence => [
    '<Tab> text ks=http://%IP%:%PORT%/ks.cfg<Enter>'
  ],
  :kickstart_port => "7122",
  :kickstart_timeout => 300,
  :kickstart_file => "ks.cfg",
  :ssh_login_timeout => "10000",
  :ssh_user => "vagrant",
  :ssh_password => "vagrant",
  :ssh_key => "",
  :ssh_host_port => "7222",
  :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd => "/sbin/halt -h -p",
  :postinstall_files => [
    "base.sh",
    "ruby.sh",
    "chef.sh",
    "puppet.sh",
    "vagrant.sh",
    "virtualbox.sh",
    #"kvm.sh",
    #"vmfusion.sh",
    "cleanup.sh",
    "zerodisk.sh"
  ],
  :postinstall_timeout => 10000
})
