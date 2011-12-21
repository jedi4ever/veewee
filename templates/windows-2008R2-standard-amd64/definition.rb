# -*- coding: utf-8 -*-
Veewee::Session.declare({
    :os_type_id => 'Windows2008_64',
    :iso_file => "7601.17514.101119-1850_x64fre_server_eval_en-us-GRMSXEVAL_EN_DVD.iso",
    :iso_md5 => "4263be2cf3c59177c45085c0a7bc6ca5",
    :iso_src => "",
    :iso_download_timeout => "1000",

    :cpu_count => '1',
    :memory_size=> '384', 
    :disk_size => '10140', :disk_format => 'VDI', :hostiocache => 'off',

    :floppy_files => [
      "Autounattend.xml", # automate install and setup winrm
      "cygwin-setup.exe",
      "install-cygwin-sshd.bat",
      "install-winrm.bat",
      "oracle-cert.cer"],

    :boot_wait => "35",
    # after 35 seconds, hit these keys to not enter a product key and fully automate the install
    # if your machine is slower it may take more time
    :boot_cmd_sequence => [ 
    '<Tab><Tab><Tab><Enter>',
    '<Enter>'
    ]

    :ssh_login_timeout => "10000",
    # Actively attempt to winrm (no ssh on base windows) in for 10000 seconds
    :ssh_user => "vagrant", :ssh_password => "vagrant", :ssh_key => "", 
    :ssh_host_port => "59856", :ssh_guest_port => "5985",
    # And run postinstall.sh for up to 10000 seconds
    :postinstall_timeout => "10000",
    :postinstall_files => ["postinstall.sh"],
    # No sudo on windows
    :sudo_cmd => "sh '%f'",
    # Shutdown is different as well
    :shutdown_cmd => "shutdown /p /t 60 /c \"Vagrant Shutdown\" /f /d p:4:1",
})


