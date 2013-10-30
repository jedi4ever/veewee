require 'net/http'

template_uri   = 'http://distfiles.gentoo.org/releases/x86/autobuilds/latest-install-x86-minimal.txt'
template_build = Net::HTTP.get_response(URI.parse(template_uri)).body
template_build = /^(([^#].*)\/(.*))/.match(template_build)

Veewee::Definition.declare({
  :cpu_count   => 2,
  :memory_size => '1024',
  :disk_size   => '20280',
  :disk_format => 'VDI',
  :hostiocache => 'off',
  :os_type_id  => 'Gentoo',
  :iso_file    => template_build[3],
  :iso_src     => "http://distfiles.gentoo.org/releases/x86/autobuilds/#{template_build[1]}",
  :iso_download_timeout => 1000,
  :boot_wait => "10",
  :boot_cmd_sequence => [
    '<Wait>' * 2,
    'gentoo-nofb<Enter>',
    '<Wait>' * 30,
    '<Enter>',
    '<Wait>' * 20,
    'passwd<Enter><Wait><Wait>',
    'vagrant<Enter><Wait>',
    'vagrant<Enter><Wait>',
    '/etc/init.d/sshd start<Enter>'
  ],
  :kickstart_port    => '7122',
  :kickstart_timeout => 10000,
  :kickstart_file    => '',
  :ssh_login_timeout => '10000',
  :ssh_user          => 'root',
  :ssh_password      => 'vagrant',
  :ssh_key           => '',
  :ssh_host_port     => '7222',
  :ssh_guest_port    => '22',
  :sudo_cmd          => "cat '%f'|su -",
  :shutdown_cmd      => 'shutdown -hP now',
  :postinstall_files => [
    'settings.sh',
    'base.sh',
    'kernel.sh',
    'usb.sh',
    'git.sh',
    'subversion.sh',
    'virtualbox.sh',
    'vagrant.sh',
    'ruby.sh',
    'add_chef.sh',
    'add_puppet.sh',
    'add_vim.sh',
    'cron.sh',
    'syslog.sh',
    'nfs.sh',
    'grub.sh',
    'wipe_sources.sh',
    'cleanup.sh',
    'zerodisk.sh',
    'reboot.sh'
  ],
  :postinstall_timeout => 10000
})
