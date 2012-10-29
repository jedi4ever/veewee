require 'net/http'

# Name spacing variables as they are executed inside veewee code
template_uri = 'http://distfiles.gentoo.org/releases/x86/autobuilds/latest-install-x86-minimal.txt'
template_build = Net::HTTP.get_response( URI.parse( template_uri ) ).body
template_build = /^(([^#].*)\/(.*))/.match( template_build )
template_uri = "http://distfiles.gentoo.org/releases/x86/autobuilds/#{template_build[1]}.DIGESTS"
template_digest = Net::HTTP.get_response( URI.parse( template_uri ) ).body
template_digest = Regexp.new( '^([a-z0-9]{32})\s+ ' + Regexp.escape( template_build[3] ) + '$').match( template_digest )[1]


Veewee::Definition.declare( {
  :cpu_count => '1', :memory_size=> '768',
  :disk_size => '10140', :disk_format => 'VDI',:hostiocache => 'off',
  :os_type_id => 'Gentoo',
  :iso_file => template_build[3],
  :iso_src => "http://distfiles.gentoo.org/releases/x86/autobuilds/#{template_build[1]}",
  :iso_md5 => template_digest,
  :iso_download_timeout => "1000",
  :boot_wait => "10",:boot_cmd_sequence => [
        '<Wait>'*2,
        'gentoo-nofb<Enter>',
        '<Wait>'*10,
        '<Enter>',
        '<Wait>'*10,
        'net-setup eth0<Enter>',
        '<Wait><Enter>',
        '2<Enter>',
        '1<Enter>',
  '<Wait><Wait>ifconfig -a <Enter>',
  #'sleep 5 ;curl http://%IP%:%PORT%/stages.sh -o stages.sh &&',
  #'bash stages.sh &<Enter>',
        'passwd<Enter><Wait><Wait>',
  'vagrant<Enter><Wait>',
  'vagrant<Enter><Wait>',
        '/etc/init.d/sshd start<Enter>'
    ],
  :kickstart_port => "7122", :kickstart_timeout => "10000",:kickstart_file => "",
  :ssh_login_timeout => "10000",:ssh_user => "root", :ssh_password => "vagrant",:ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "cat '%f'|su -",
  :shutdown_cmd => "shutdown -p now",
  :postinstall_files => [ "postinstall.sh"],:postinstall_timeout => "10000"
   }
)
