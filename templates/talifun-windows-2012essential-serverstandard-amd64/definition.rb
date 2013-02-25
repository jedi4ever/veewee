# -*- coding: utf-8 -*-
Veewee::Session.declare({
    :os_type_id => 'Windows2012_64',
    # http://technet.microsoft.com/en-us/evalcenter/dd459137.aspx
    # Download and install full featured software for 180-day trial
    :iso_file => "WindowsServer2012Essentials-English-Install.iso",
    :iso_md5 => "14E585F7DC29E9A62800D3BDA3892E45",
    :iso_src => "http://care.dlservice.microsoft.com//dl/download/1/2/9/129AEC4F-1C6C-44B2-9B61-77935E8AB1F4/WindowsServer2012Essentials-English-Install.iso",
    :iso_download_timeout => "1000",
    :cpu_count => '1',
    :memory_size=> '2048', 
    :disk_size => '20280', :disk_format => 'VDI', :hostiocache => 'off',

    :floppy_files => [
      "Autounattend.xml",
      "oracle-cert.cer"
    ],

    :boot_wait => "1",
    :boot_cmd_sequence => [''],
    :winrm_user => "vagrant", :winrm_password => "vagrant",
    :kickstart_port => "7100",
    :postinstall_timeout => "10000",
    :postinstall_files => [
      "install-chef.bat",
      "install-vbox.bat"
    ],
    :sudo_cmd => "%f",
    :shutdown_cmd => "shutdown /s /t 10  /f /d p:4:1 /c \"Vagrant Shutdown\"" ,
    # :shutdown_cmd => "shutdown /s /t 60 /d p:4:1 /c \"Vagrant Shutdown\"",
})


