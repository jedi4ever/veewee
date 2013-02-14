Veewee::Definition.declare({
  :cpu_count => '1', :memory_size=> '768',
  :disk_size => '10140', :disk_format => 'VDI', :hostiocache => 'off',
  :os_type_id => 'FreeBSD_64',
  :iso_file => "PCBSD9.1-x64-DVD.iso",
  :iso_src => "http://mirrors.isc.org/pub/pcbsd/9.1/amd64/PCBSD9.1-x64-DVD.iso",
  :iso_md5 => "d48c1493726b7f36b5ac0635d9b6e838",
  :iso_download_timeout => "1000",
  :boot_wait => "70", :boot_cmd_sequence => [
    '<KillX>',
    '<Enter>',
    'dhclient em0<Enter>',
    'echo "waiting for 25 seconds"',
    'sleep 25;echo "Lets Get the File";fetch "http://%IP%:%PORT%/pcinstall.fbg.cfg";sleep 2;',
    'echo \'echo sshd_enable=\"YES\" >> $FSMNT/etc/rc.conf\' > /root/activate-ssh.sh ; cat /root/activate-ssh.sh<Enter>',
    'chmod +x /root/activate-ssh.sh<Enter>',
    'echo "Hope i got the file";/usr/PCBSD/pc-sysinstall/pc-sysinstall -c /root/pcinstall.fbg.cfg<Enter>',
    'reboot<Enter>'
  ],
  :kickstart_port => "7122", :kickstart_timeout => "10000", :kickstart_file => "pcinstall.fbg.cfg",
  :ssh_login_timeout => "10000", :ssh_user => "vagrant", :ssh_password => "vagrant", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "cat '%f'|su -",
  :shutdown_cmd => "shutdown -p now",
  :postinstall_files => [ "postinstall.sh"], :postinstall_timeout => "10000"
})
