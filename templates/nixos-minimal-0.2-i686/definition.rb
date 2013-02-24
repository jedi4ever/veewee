iso = {
  :url => 'http://nixos.org/releases/nixos/nixos-0.2pre4476_a5e4432-b076ab9/nixos-minimal-0.2pre4476_a5e4432-b076ab9-i686-linux.iso',
  :md5  => 'f035bb375f0fbcbbc4e33a12131e91d4',
}

session = {
  :boot_cmd_sequence =>
  [
   '<Enter>', '<Wait>'*15,
   'root',                                              '<Enter>',
   'stop sshd',                                         '<Enter>', # Make sure we don't accept connections until reboot
   'fdisk /dev/sda',                                    '<Enter>',
   'n',                                                 '<Enter>'*5,
   'a',                                                 '<Enter>',
   '1',                                                 '<Enter>',
   'w',                                                 '<Enter>',
   'mkfs.ext4 -j -L nixos /dev/sda1',                   '<Enter>',
   'mount LABEL=nixos /mnt',                            '<Enter>',
   'nixos-option --install',                            '<Enter>',
   'curl http://%IP%:%PORT%/configuration.nix > /mnt/etc/nixos/configuration.nix &&', '<Enter>',
   'nixos-install &&',                                  '<Enter>',
   'reboot',                                            '<Enter>',
  ],
  :boot_wait            => '5',
  :cpu_count            => '1',
  :disk_format          => 'VDI',
  :disk_size            => '20400',
  :hostiocache          => 'off',
  :iso_download_timeout => '1000',
  :iso_file             => File.basename(iso[:url]),
  :iso_md5              => iso[:md5],
  :iso_src              => iso[:url],
  :kickstart_file       => 'configuration.nix',
  :kickstart_port       => '7122',
  :kickstart_timeout    => '10000',
  :memory_size          => '256',
  :os_type_id           => 'Linux26',
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
