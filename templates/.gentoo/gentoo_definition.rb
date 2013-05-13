uri = "http://distfiles.gentoo.org/releases/#{ARCHITECTURE}/autobuilds"
template_uri   = "#{uri}/latest-install-#{ARCHITECTURE}-minimal.txt"
template_build = Net::HTTP.get_response(URI.parse(template_uri)).body
template_build = /^(([^#].*)\/(.*))/.match(template_build)

case ARCHITECTURE
when "amd64"
  os_type_id = 'Gentoo_64'
when "x86"
  os_type_id = 'Gentoo'
end

GENTOO_SESSION =
  COMMON_SESSION.merge( 
    {
      :ssh_user   => "root",
      # variables related to initiate the gentoo 
      :cpu_count  => "2",
      :os_type_id => os_type_id,
      :iso_file   => template_build[3],
      :iso_src    => "#{uri}/#{template_build[1]}",
      # boot the VM
      :boot_cmd_sequence =>
      [
        '<Wait>' * 2,
        'gentoo-nofb<Enter>',
        '<Wait>' * 30,
        '<Enter>',
        '<Wait>' * 20,
        '<Wait><Wait>ifconfig -a<Enter>',
        'passwd<Enter><Wait><Wait>',
        'vagrant<Enter><Wait>',
        'vagrant<Enter><Wait>',
        '/etc/init.d/sshd start<Enter>'
      ],
      :postinstall_files => 
      [ 'architecture_settings.sh',
        'settings.sh',
        'base.sh',
        'kernel.sh',
        'virtualbox.sh',
        'vagrant.sh',
        'cron.sh',
        'syslog.sh',
        'nfs.sh',
        'grub.sh',
        'reboot.sh',
        'chef.sh',
        'puppet.sh',
        'cleanup.sh',
        'zerodisk.sh'                        
      ],
      :kickstart_file => '',
      :shutdown_cmd => "/sbin/shutdown -hP now",
      :postinstall_timeout => "10000" 
  }
  )
