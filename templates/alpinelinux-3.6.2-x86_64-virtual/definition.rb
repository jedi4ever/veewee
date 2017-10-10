require 'net/http'

iso_name = 'alpine-virt-3.6.2-x86_64.iso'
iso_mirror = 'http://dl-cdn.alpinelinux.org/alpine/v3.6/releases/x86_64'
iso_uri = "#{iso_mirror}/#{iso_name}"
check_sum = "#{iso_mirror}/#{iso_name}.sha256"

root_password = 'veewee'

Veewee::Definition.declare({
  :cpu_count   => "1",
  :memory_size => "256",
  :disk_size   => "10140",
  :disk_format => "VDI",
  :hostiocache => "off",
  :os_type_id  => "Linux26_64",
  :iso_file    => iso_name,
  :iso_src     => iso_uri,
  :iso_sha256  => check_sum,
  :iso_download_timeout => "1000",
  :boot_wait   => "5",
  :boot_cmd_sequence => [
    '<Enter>',
    '<Wait30>',
    'root<Enter>',
    'ifconfig eth0 up<Enter>',
    'udhcpc eth0<Enter>',
    'passwd<Enter>',
    "#{root_password}<Enter>",
    "#{root_password}<Enter>",
    'setup-apkrepos -1<Enter>',
    'apk add openssh<Enter>',
    'echo "PermitRootLogin yes" >> /etc/ssh/sshd_config<Enter>',
    '/etc/init.d/sshd start<Enter>',
  ],
  :ssh_login_timeout => "10000",
  :ssh_user          => "root",
  :ssh_password      => "#{root_password}",
  :ssh_key           => "",
  :ssh_host_port     => "7222",
  :ssh_guest_port    => "22",
  :sudo_cmd          => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd      => "poweroff",
  :postinstall_files => [
    'settings.sh',
    'base.sh',
    'sudo.sh',
    'user.sh',
    'apk.sh',
    'virtualbox.sh',
    'vagrant.sh',
    # 'aports.sh',
    'ruby.sh',
    'puppet.sh',
    'chef.sh',
    'cleanup.sh',
    'zerodisk.sh',
    'reboot.sh',
  ],
  :postinstall_timeout => "10000",
  :params => {
    #:PACMAN_REFLECTOR_ARGS => '--verbose -l 5 --sort rate --save /etc/pacman.d/mirrorlist',
  }
})
