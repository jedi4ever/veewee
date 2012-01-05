# -*- coding: utf-8 -*-
#video memory size should be at least 32meg for windows 7 to do full screen on my desktop
# I'm not sure how to set that with veewee::session yet
Veewee::Session.declare({
    :os_type_id => 'Windows7_64',
    :iso_file => "X17-24395.iso",
    # https://sites.google.com/site/linuxlablibrary/windows-7-iso
    :iso_src => "http://msft.digitalrivercontent.net/win/X17-24395.iso",
    :iso_md5 => "56a26636ec667799f5a7f42f142c772d",
    :iso_download_timeout => "100000",

    :cpu_count => '1',
    :memory_size=> '512', 
    :disk_size => '20280', :disk_format => 'VDI', :hostiocache => 'off',
    
    :floppy_files => [
      "Autounattend.xml",
      "install-winrm.bat",
      "oracle-cert.cer",
      "install-cygwin-sshd.bat"
    ],


    :boot_wait => "720", #12 minutes.. should be long enough
    # this is waiting for the screene where we could put in our product key
    # this is the command sequence to bybass it and to not try to register once online
    :boot_cmd_sequence => [ 
      '<Tab><Spacebar><Tab><Tab><Tab><Spacebar>'
    ],

    :ssh_login_timeout => "10000",
    # Actively attempt to winrm (no ssh on base windows) in for 10000 seconds
    :ssh_user => "vagrant", :ssh_password => "vagrant", :ssh_key => "", 
    :ssh_host_port => "59857", :ssh_guest_port => "22",
    # And run postinstall.sh for up to 10000 seconds
    :postinstall_timeout => "10000",
    :postinstall_files => ["postinstall.sh"],
    # No sudo on windows
    :sudo_cmd => "sh '%f'",
    # Shutdown is different as well
    :shutdown_cmd => "shutdown /s /t 0 /c \"Vagrant Shutdown\" /f /d p:4:1",
  })
