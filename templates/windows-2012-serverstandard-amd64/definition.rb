# -*- coding: utf-8 -*-
Veewee::Session.declare({
    :os_type_id => 'Windows8_64',
    :iso_download_instructions => "Download and install full featured software for 180-day trial at http://technet.microsoft.com/en-US/evalcenter/hh670538.aspx",
    :iso_file => "9200.16384.WIN8_RTM.120725-1247_X64FRE_SERVER_EVAL_EN-US-HRM_SSS_X64FREE_EN-US_DV5.ISO",
    :iso_md5 => "8503997171f731d9bd1cb0b0edc31f3d",
    :iso_src => "http://care.dlservice.microsoft.com//dl/download/6/D/A/6DAB58BA-F939-451D-9101-7DE07DC09C03/9200.16384.WIN8_RTM.120725-1247_X64FRE_SERVER_EVAL_EN-US-HRM_SSS_X64FREE_EN-US_DV5.ISO",
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
})
