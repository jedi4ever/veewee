# -*- coding: utf-8 -*-
#video memory size should be at least 32meg for windows 7 to do full screen on my desktop
# I'm not sure how to set that with veewee::session yet
Veewee::Session.declare({
    :os_type_id => 'Windows7_64',
    # http://technet.microsoft.com/en-us/evalcenter/cc442495.aspx
    # The 90-day Trial is offered for a limited time and in limited quantity.
    # The download will be available through June 30th, 2012, while supplies last.
    :iso_file => "7600.16385.090713-1255_x64fre_enterprise_en-us_EVAL_Eval_Enterprise-GRMCENXEVAL_EN_DVD.iso",
    :iso_src => "http://wb.dlservice.microsoft.com/dl/download/release/Win7/3/b/a/3bac7d87-8ad2-4b7a-87b3-def36aee35fa/7600.16385.090713-1255_x64fre_enterprise_en-us_EVAL_Eval_Enterprise-GRMCENXEVAL_EN_DVD.iso",
    :iso_md5 => "1d0d239a252cb53e466d39e752b17c28",
    :iso_download_timeout => "100000",

    :cpu_count => '1',
    :memory_size=> '512', 
    :disk_size => '20280', :disk_format => 'VDI', :hostiocache => 'off',
    
    :floppy_files => [
      "Autounattend.xml",
      "install-vbox-guest.bat",
      "install-winrm.bat",
      "install-cygwin-sshd.bat",
      "oracle-cert.cer"
    ],

    :boot_wait => "1", #12 minutes
    :boot_cmd_sequence => [''],

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
    :shutdown_cmd => "shutdown /s /t 60 /c \"Vagrant Shutdown\" /f /d p:4:1",
  })
