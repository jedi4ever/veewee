# go to last line to change installation media
opensuse_32_dvd = {
  :os_type_id  => 'OpenSUSE',
  :iso_file => "openSUSE-13.1-DVD-i586.iso",
  :iso_src  => "http://download.opensuse.org/distribution/13.1/iso/openSUSE-13.1-DVD-i586.iso",
  :iso_md5  => "1bd6223430910f6d5a168d4e19171462",
  :boot_cmd_sequence => [
    '<Esc><Enter>',
    'linux netdevice=enp0s3 netsetup=dhcp install=cd:/ lang=en_US autoyast=http://%IP%:%PORT%/autoinst.xml textmode=1',
    '<Enter>'
  ],
}
opensuse_32_net = {
  :os_type_id  => 'OpenSUSE',
  :iso_file => "openSUSE-13.1-NET-i586.iso",
  :iso_src  => "http://download.opensuse.org/distribution/13.1/iso/openSUSE-13.1-NET-i586.iso",
  :iso_md5  => "6d3c77f72ae4318439ddf5ad890b7687",
  :boot_cmd_sequence => [
    '<Esc><Enter>',
    'linux netdevice=enp0s3 netsetup=dhcp install=http://download.opensuse.org/distribution/13.1/repo/oss/',
    ' insecure=1 lang=en_US autoyast=http://%IP%:%PORT%/autoinst.xml textmode=1',
    '<Enter>'
  ],
}
opensuse_64_dvd = {
  :os_type_id  => 'OpenSUSE_64',
  :iso_file => "openSUSE-13.1-DVD-x86_64.iso",
  :iso_src  => "http://download.opensuse.org/distribution/13.1/iso/openSUSE-13.1-DVD-x86_64.iso",
  :iso_md5  => "1096c9c67fc8a67a94a32d04a15e909d",
  :boot_cmd_sequence => [
    '<Esc><Enter>',
    'linux netdevice=enp0s3 netsetup=dhcp install=cd:/ lang=en_US autoyast=http://%IP%:%PORT%/autoinst.xml textmode=1',
    '<Enter>'
  ],
}
opensuse_64_net = {
  :os_type_id  => 'OpenSUSE_64',
  :iso_file => "openSUSE-13.1-NET-x86_64.iso",
  :iso_src  => "http://download.opensuse.org/distribution/13.1/iso/openSUSE-13.1-NET-x86_64.iso",
  :iso_md5  => "6c0d656895cbd92f34de61d98ca364ea",
  :boot_cmd_sequence => [
    '<Esc><Enter>',
    'linux netdevice=enp0s3 netsetup=dhcp install=http://download.opensuse.org/distribution/13.1/repo/oss/',
    ' insecure=1 lang=en_US autoyast=http://%IP%:%PORT%/autoinst.xml textmode=1',
    '<Enter>'
  ],
}

Veewee::Definition.declare({
  :cpu_count   => '2',
  :memory_size => '1024',
  :disk_size   => '20480',
  :disk_format => 'VDI',
  :hostiocache => 'off',
  :iso_download_timeout => "1000",
  :boot_wait         => "10",
  :kickstart_port    => "7122",
  :kickstart_timeout => "10000",
  :kickstart_file    => ["autoinst.xml", "autoinst.xml"],
  :ssh_login_timeout => "10000",
  :ssh_user          => "root",
  :ssh_password      => "vagrant",
  :ssh_key           => "",
  :ssh_host_port     => "7222",
  :ssh_guest_port    => "22",
  :sudo_cmd     => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd => "shutdown -P now",
  :postinstall_files   => ["postinstall.sh"],
  :postinstall_timeout => "10000",
}.merge( opensuse_64_dvd )) # change opensuse_64_dvd to one of configuratiosn defined on top
