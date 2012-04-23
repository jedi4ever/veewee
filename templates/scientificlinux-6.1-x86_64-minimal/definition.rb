Veewee::Session.declare({
  :cpu_count => '1',
  :memory_size=> '512',
  :disk_size => '10140',
  :disk_format => 'VDI',
  :hostiocache => 'off',
  :virtualbox => {
    :vm_options => [
       # NOTE: "On any host, you should enable the I/O APIC for virtual machines that you intend
       # to use in 64-bit mode" (http://www.virtualbox.org/manual/ch03.html). But also read
       # https://forums.virtualbox.org/viewtopic.php?f=7&t=47106 (only applies to Windows?).
      'ioapic' => 'on',
      # NOTE: "Some operating systems (such as Ubuntu Server) require PAE support from the CPU
      # and cannot be run in a virtual machine without it" (http://www.virtualbox.org/manual/ch03.html -
      # not clear if this is required for Scientific Linux, but the CentOS definitions set it).
      'pae' => 'on'
    ]
  },
  :os_type_id => 'RedHat_64',
  :iso_file => "SL-61-x86_64-2011-07-27-boot.iso",
  :iso_src => "http://mirrors.200p-sf.sonic.net/scientific/6.1/x86_64/iso/SL-61-x86_64-2011-07-27-boot.iso",
  :iso_md5 => "863841b65b5b42f7ad0e735bb9aa669d",
  :iso_download_timeout => 1000,
  :boot_wait => "15",
  :boot_cmd_sequence => [ '<Tab> text ks=http://%IP%:%PORT%/ks.cfg<Enter>' ],
  :kickstart_port => "7122",
  :kickstart_timeout => 10000,
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
    "vagrant.sh",
    "virtualbox.sh",
    "cleanup.sh"
  ],
  :postinstall_timeout => 10000
})