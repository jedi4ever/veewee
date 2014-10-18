# Download Windows Server 2008 Enterprise: (60 day eval, expandable to 240 days)
# http://www.microsoft.com/download/en/details.aspx?id=8371
# 64bit
# http://download.microsoft.com/download/B/4/D/B4DC75A1-D7D2-4F31-87F9-E02C950E8D31/6001.18000.080118-1840_amd64fre_Server_en-us-KRMSXFRE_EN_DVD.iso
# md5sum 0477c88678efb8ebc5cd7a9e9efd8b82  6001.18000.080118-1840_amd64fre_Server_en-us-KRMSXFRE_EN_DVD.iso
# 32bit
# http://download.microsoft.com/download/B/4/D/B4DC75A1-D7D2-4F31-87F9-E02C950E8D31/6001.18000.080118-1840_x86fre_Server_en-us-KRMSFRE_EN_DVD.iso



# Win2008 requires at least 10gig hard drive to install...

Veewee::Session.declare({
    :os_type_id => 'Windows2008_64',
    :iso_file => "6001.18000.080118-1840_amd64fre_Server_en-us-KRMSXFRE_EN_DVD.iso",
    :iso_md5 => "0477c88678efb8ebc5cd7a9e9efd8b82",
    :iso_src => "http://download.microsoft.com/download/B/4/D/B4DC75A1-D7D2-4F31-87F9-E02C950E8D31/6001.18000.080118-1840_amd64fre_Server_en-us-KRMSXFRE_EN_DVD.iso",
    :iso_download_timeout => "1000",

    :cpu_count => '1',
    :memory_size=> '384',
    :disk_size => '20280', :disk_format => 'VDI', :hostiocache => 'off',


    #:kickstart_port => "7122",
    #:kickstart_timeout => 300,
    #:kickstart_file => ["VBoxWindowsAdditions-amd64.exe"],

    :floppy_files => [
      "Autounattend.xml", # automate install and setup winrm
      "install-winrm.bat",
      "install-cygwin-sshd.bat",
      "cygwin-setup.exe",
      "oracle-cert.cer"
    ],

    :boot_wait => "50",
    # after 40 seconds, hit these keys to not enter a product key and fully automate the install
    # if your machine is slower it may take more time
    :boot_cmd_sequence => [
      '<Tab><Tab><Spacebar>',
      '<Tab><Tab><Tab><Spacebar>',
      '<Tab><Spacebar>'
    ],

    :ssh_login_timeout => "10000",
    # Actively attempt to ssh in for 10000 seconds
    :ssh_user => "vagrant", :ssh_password => "vagrant", :ssh_key => "",
    :ssh_host_port => "7233", :ssh_guest_port => "22",
    # And run postinstall.sh for up to 10000 seconds
    :postinstall_timeout => "10000",
    :postinstall_files => ["postinstall.sh"],
    # No sudo on windows
    :sudo_cmd => "sh '%f'",
    # Shutdown is different as well
    :shutdown_cmd => "shutdown /s /t 0 /d P:4:1 /c \"Vagrant Shutdown\"",
})


# To edit the Autounattend.xml and validate it:
# Download Automated Installation Kit (AIK) for Windows Vista SP1 and Windows Server 2008:
# http://www.microsoft.com/download/en/details.aspx?id=9085
# Resulting in 6001.18000.080118-1840-kb3aikl_en.iso
# md5sum b83fad8fd28e637b82cb4a6bef7d6920 6001.18000.080118-1840-kb3aikl_en.iso

# AIK also includes dism, which will allow you to choose a specific version:

# If you want to install a different version, edit Autoattended.xml and replace the /IMAGE/NAME value with
# one of the names listed in the Longhorn install.wim on the install .iso

# <InstallFrom>
#     <MetaData wcm:action="add">
#         <Key>/IMAGE/NAME</Key>
#         <Value>Windows Longhorn SERVERSTANDARD</Value> ### This comes from the Name: field below
#     </MetaData>
# </InstallFrom>

# PS C:\Users\Administrator> Dism /Get-WIMInfo /WimFile:d:\sources\install.wim

# Deployment Image Servicing and Management tool
# Version: 6.1.7600.16385

# Details for image : d:\sources\install.wim

# Index : 1
# Name : Windows Longhorn SERVERSTANDARD
# Description : Windows Longhorn SERVERSTANDARD
# Size : 8,784,297,519 bytes

# Index : 2
# Name : Windows Longhorn SERVERENTERPRISE
# Description : Windows Longhorn SERVERENTERPRISE
# Size : 8,792,036,862 bytes

# Index : 3
# Name : Windows Longhorn SERVERDATACENTER
# Description : Windows Longhorn SERVERDATACENTER
# Size : 8,792,568,645 bytes

# Index : 4
# Name : Windows Longhorn SERVERSTANDARDCORE
# Description : Windows Longhorn SERVERSTANDARDCORE
# Size : 2,512,939,954 bytes

# Index : 5
# Name : Windows Longhorn SERVERENTERPRISECORE
# Description : Windows Longhorn SERVERENTERPRISECORE
# Size : 2,522,686,340 bytes

# Index : 6
# Name : Windows Longhorn SERVERDATACENTERCORE
# Description : Windows Longhorn SERVERDATACENTERCORE
# Size : 2,522,615,418 bytes
