# -*- coding: utf-8 -*-
#video memory size should be at least 32meg for windows 7 to do full screen on my desktop
# I'm not sure how to set that with veewee::session yet
Veewee::Session.declare({
    :os_type_id => 'Windows7_64',
    # Windows 7 Enterprise 90-day Trial
    # http://technet.microsoft.com/en-us/evalcenter/cc442495.aspx 
    :iso_file => "7600.16385.090713-1255_x64fre_enterprise_en-us_EVAL_Eval_Enterprise-GRMCENXEVAL_EN_DVD.iso",
    :iso_src => "http://wb.dlservice.microsoft.com/dl/download/release/Win7/3/b/a/3bac7d87-8ad2-4b7a-87b3-def36aee35fa/7600.16385.090713-1255_x64fre_enterprise_en-us_EVAL_Eval_Enterprise-GRMCENXEVAL_EN_DVD.iso",
    :iso_md5 => "1d0d239a252cb53e466d39e752b17c28",
    :iso_download_timeout => "100000",
    :cpu_count => '1',
    :memory_size=> '512', 
    :disk_size => '20280', :disk_format => 'VDI', :hostiocache => 'off',
    :floppy_files => [
      "Autounattend.xml",
      "oracle-cert.cer"
    ],
    :winrm_user => "vagrant", :winrm_password => "vagrant",
    :postinstall_timeout => "10000",
    :postinstall_files => [
      "install-chef.bat",
      "install-vbox.bat"
    ],
    :shutdown_cmd => "shutdown /s /t 10 /c \"Vagrant Shutdown\" /f /d p:4:1",
  })
