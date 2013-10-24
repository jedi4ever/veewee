# -*- coding: utf-8 -*-
Veewee::Session.declare({
    :os_type_id => 'Windows8_64',
    :iso_download_instructions => "Download and install full featured software for 180-day trial at http://technet.microsoft.com/en-US/evalcenter/hh670538.aspx",
    :iso_file => "9600.16384.WINBLUE_RTM.130821-1623_X64FRE_SERVER_EVAL_EN-US-IRM_SSS_X64FREE_EN-US_DV5.ISO",
    :iso_md5 => "458ff91f8abc21b75cb544744bf92e6a",
    :iso_src => "http://care.dlservice.microsoft.com/dl/download/6/2/A/62A76ABB-9990-4EFC-A4FE-C7D698DAEB96/9600.16384.WINBLUE_RTM.130821-1623_X64FRE_SERVER_EVAL_EN-US-IRM_SSS_X64FREE_EN-US_DV5.ISO",
    :iso_download_timeout => "1000",
    :cpu_count => '1',
    :memory_size=> '512', 
    :disk_size => '10140', :disk_format => 'VDI', :hostiocache => 'off',

    :floppy_files => [
      "Autounattend.xml", 
      "oracle-cert.cer"],

    :boot_wait => "1",
    :boot_cmd_sequence => [''],

    :kickstart_port => "7122",
    :winrm_user => "vagrant",
    :winrm_password => "vagrant",
    # And run postinstall.sh for up to 10000 seconds
    :postinstall_timeout => "10000",
    :postinstall_files => ["install-chef.bat", "install-puppet.bat", "install-vbox.bat"],
    # No sudo on windows
    :sudo_cmd => "%f",
    :shutdown_cmd => "shutdown /s /t 10 /f /d p:4:1 /c \"Vagrant Shutdown\"",

    :virtualbox => {
      :extradata => 'VBoxInternal/CPUM/CMPXCHG16B 1',
    }
})
