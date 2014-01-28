iso = {
  :file => 'nixos-minimal-13.10.35497.60b0467-x86_64-linux.iso',
  :md5  => 'db3b34cd4cf2030b1a425cd6af6a9a09',
}

session = {
  :boot_cmd_sequence =>
  [
   '<Enter>', '<Wait>'*15,
   'root',                                              '<Enter>',
   'fdisk /dev/sda',                                    '<Enter>',
   'n',                                                 '<Enter>'*5,
   'a',                                                 '<Enter>',
   '1',                                                 '<Enter>',
   'w',                                                 '<Enter>',
   'mkfs.ext4 -j -L nixos /dev/sda1',                   '<Enter>',
   'mount LABEL=nixos /mnt',                            '<Enter>',
   'curl -O http://10.0.2.2:7122/configuration.nix &&', '<Enter>',
   'mkdir -p /mnt/etc/nixos &&',                        '<Enter>',
   'mv configuration.nix /mnt/etc/nixos &&',            '<Enter>',
   'nixos-install &&',                                  '<Enter>',
   'reboot',                                            '<Enter>'
  ],
  :boot_wait            => '5',
  :cpu_count            => '1',
  :disk_format          => 'VDI',
  :disk_size            => '20400',
  :hostiocache          => 'off',
  :iso_download_timeout => '1000',
  :iso_file             => iso[:file],
  :iso_md5              => iso[:md5],
  :iso_src              => "http://releases.nixos.org/13.10/nixos-13.10.35497.60b0467/#{iso[:file]}",
  :kickstart_file       => 'configuration.nix',
  :kickstart_port       => '7122',
  :kickstart_timeout    => '10000',
  :memory_size          => '512',
  :os_type_id           => 'Linux26_64',
  :postinstall_files    => [ 'postinstall.sh' ],
  :postinstall_timeout  => '10000',
  :shutdown_cmd         => 'shutdown -h now',
  :ssh_guest_port       => '22',
  :ssh_host_port        => '7222',
  :ssh_key              => '',
  :ssh_login_timeout    => '10000',
  :ssh_password         => 'vagrant',
  :ssh_user             => 'vagrant',
  :sudo_cmd             => "sudo '%f'"
}

Veewee::Definition.declare session
