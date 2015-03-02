require 'net/http'

iso_mirror = 'http://mirrors.kernel.org/archlinux/iso/2015.03.01'
uri = "#{iso_mirror}/md5sums.txt"
response = Net::HTTP.get_response(URI.parse(uri)).body.split
iso = response[1]
iso_md5 = response[0]

root_password = 'veewee'

Veewee::Definition.declare({
  :cpu_count   => "1",
  :memory_size => "256",
  :disk_size   => "10140",
  :disk_format => "VDI",
  :hostiocache => "off",
  :os_type_id  => "ArchLinux_64",
  :iso_file    => iso,
  :iso_src     => "#{iso_mirror}/#{iso}",
  :iso_md5     => iso_md5,
  :iso_download_timeout => "1000",
  :boot_wait   => "5",
  :boot_cmd_sequence => [
    '<Enter>',
    '<Wait30>',
    'echo "sshd: ALL" > /etc/hosts.allow<Enter>',
    'passwd<Enter>',
    "#{root_password}<Enter>",
    "#{root_password}<Enter>",
    'systemctl start sshd.service<Enter><Wait>',
  ],
  :ssh_login_timeout => "10000",
  :ssh_user          => "root",
  :ssh_password      => "#{root_password}",
  :ssh_key           => "",
  :ssh_host_port     => "7222",
  :ssh_guest_port    => "22",
  :sudo_cmd          => "sh '%f'",
  :shutdown_cmd      => "shutdown -h now",
  :postinstall_files => [
    'base.sh',
    'pacman.sh',
    'bootloader.sh',
    'ssh.sh',
    'reboot.sh',
    'sudo.sh',
    'user.sh',
    'aur.sh',
    'virtualbox.sh',
    'ruby.sh',
    'chef.sh',
    'puppet.sh',
    'vagrant.sh',
    'reboot.sh',
    'cleanup.sh',
    'zerodisk.sh',
  ],
  :postinstall_timeout => "10000",
  :params => {
    #:PACMAN_REFLECTOR_ARGS => '--verbose -l 5 --sort rate --save /etc/pacman.d/mirrorlist',
  }
})
