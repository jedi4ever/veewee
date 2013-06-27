# -*- coding: utf-8 -*-
Veewee::Session.declare({
    :os_type_id => 'Windows2008_64',
    # http://technet.microsoft.com/en-us/evalcenter/dd459137.aspx
    # Download and install full featured software for 180-day trial
    :iso_file => "en_windows_server_2008_r2_with_sp1_vl_build_x64_dvd_617403.iso",
    :iso_md5 => "8d397b69135d207452a78c3c3051339d",
    :iso_src => "http://archive.org/details/zozoo11/en_windows_server_2008_r2_with_sp1_vl_build_x64_dvd_617403.iso",
    :iso_download_timeout => "1000",
    :cpu_count => '1',
    :memory_size => '384', 
    :disk_size => '10140', :disk_format => 'VMDK', :hostiocache => 'on', :controller_type => 'sata', :nonrotational => 'on',
    :virtualbox => {
      :vm_options => [
        'acpi' => 'on',
        'pae' => 'on',
        'ioapic' => 'on',
        'vram' => '30',
        'nestedpaging' => 'on',
        'rtcuseutc' => 'on',
        'nictype1' => '82545EM',
        'natbindip1' => '10.0.2.16'
      ]
    },

    :floppy_files => [
      "Autounattend.xml",
      "oracle-cert.cer",
      "Vagrant.inf",
      "Vagrant.reg"
    ],

    :boot_wait => '1',
    :winrm_user => 'vagrant',
    :winrm_password => 'vagrant',
    :winrm_login_timeout => '10000',
    :winrm_host_port => '15985',
    
    :shutdown_cmd => 'cmd.exe /c shutdown /s /t 60 /d p:4:2 /c \"Veewee Installation Shutdown\"'
})
