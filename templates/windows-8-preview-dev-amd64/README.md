You can download a free trial of Windows Server 2008 Enterprise: (60 day eval, expandable to 240 days)

From  http://www.microsoft.com/download/en/details.aspx?id=8371

64bit
url: http://download.microsoft.com/download/B/4/D/B4DC75A1-D7D2-4F31-87F9-E02C950E8D31/6001.18000.080118-1840_amd64fre_Server_en-us-KRMSXFRE_EN_DVD.iso
filename: 6001.18000.080118-1840_amd64fre_Server_en-us-KRMSXFRE_EN_DVD.iso
md5sum: 0477c88678efb8ebc5cd7a9e9efd8b82  


32bit
url: http://download.microsoft.com/download/B/4/D/B4DC75A1-D7D2-4F31-87F9-E02C950E8D31/6001.18000.080118-1840_x86fre_Server_en-us-KRMSFRE_EN_DVD.iso


- place it in a directory called iso

The installation uses the Standard way for Windows Unattended installation. The XML file was created using the Windows AIK kit, but the file can also be edited by hand.

You can download Automated Installation Kit (AIK) for Windows Vista SP1 and Windows Server 2008:
from http://www.microsoft.com/download/en/details.aspx?id=9085
file: 6001.18000.080118-1840-kb3aikl_en.iso
md5sum: b83fad8fd28e637b82cb4a6bef7d6920

- Building the machine creates a floppy that contains:
  - AutoUnattend.xml (that will configure the windows)
  - winrm-install.bat (activates the http and https listener + punches the firewall hole)

AIK also includes dism, which will allow you to choose a specific version:

If you want to install a different version, edit Autoattended.xml and replace the /IMAGE/NAME value with
one of the names listed in the Longhorn install.wim on the install .iso

<InstallFrom>
    <MetaData wcm:action="add">
        <Key>/IMAGE/NAME</Key>
        <Value>Windows Longhorn SERVERSTANDARD</Value> ### This comes from the Name: field below
    </MetaData>
</InstallFrom>

PS C:\Users\Administrator> Dism /Get-WIMInfo /WimFile:d:\sources\install.wim

Deployment Image Servicing and Management tool
Version: 6.1.7600.16385

Details for image : d:\sources\install.wim

Index : 1
Name : Windows Longhorn SERVERSTANDARD
Description : Windows Longhorn SERVERSTANDARD
Size : 8,784,297,519 bytes

Index : 2
Name : Windows Longhorn SERVERENTERPRISE
Description : Windows Longhorn SERVERENTERPRISE
Size : 8,792,036,862 bytes

Index : 3
Name : Windows Longhorn SERVERDATACENTER
Description : Windows Longhorn SERVERDATACENTER
Size : 8,792,568,645 bytes

Index : 4
Name : Windows Longhorn SERVERSTANDARDCORE
Description : Windows Longhorn SERVERSTANDARDCORE
Size : 2,512,939,954 bytes

Index : 5
Name : Windows Longhorn SERVERENTERPRISECORE
Description : Windows Longhorn SERVERENTERPRISECORE
Size : 2,522,686,340 bytes

Index : 6
Name : Windows Longhorn SERVERDATACENTERCORE
Description : Windows Longhorn SERVERDATACENTERCORE
Size : 2,522,615,418 bytes


This gets us nearly there, but we still need a winrm provisioner, as I don't like having to install cygwin.

Expose the winrm port:

<pre>
$ gem install chef
$ gem install knife-windows
#Create a tunnel
$ ssh -p 7222 -L5985:localhost:5985 vagrant@localhost
$ knife bootstrap windows winrm localhost -x Administrator -P 'vagrant'
</pre>


- http://wiki.opscode.com/display/chef/Knife+Windows+Bootstrap
- https://github.com/opscode/knife-windows/blob/master/lib/chef/knife/bootstrap/windows-shell.erb

- https://github.com/zenchild/WinRM

- http://devopscloud.net/2011/04/17/managing-chef-from-windows-7/
- http://devopscloud.net/2011/04/28/powershell-userdata-to-start-a-chef-run/
- http://devopscloud.net/2011/03/23/dissection-of-a-chef-recipe-or-two-for-windows/
- https://github.com/pmorton/chef-windows-installer

==
https://github.com/zenchild/WinRM/issues/unreads#issue/1
http -> requires unencryptedwinrm quickconfig (said yes to enable firewall)
winrm p winrm/config/service @{AllowUnencrypted="true"}
winrm set winrm/config/service/auth @{Basic="true"}netsh advfirewall firewall set rule group="remote administration" new enable=yes
 
- http://forums.citrix.com/thread.jspa?messageID=1535826
- http://support.microsoft.com/kb/2019527

winrm get winrm/config

The purpose of configuring WinRM for HTTPS is to encrypt the data being sent across the wire.

WinRM HTTPS requires a local computer "Server Authentication" certificate with a CN matching the hostname, that is not expired, revoked, or self-signed to be installed.

To install or view certificates for the local computer:

- click Start, run, MMC, "File" menu, "Add or Remove Snap-ins" select "Certificates" and click "Add".  Go through the wizard selecting "Computer account".

- Install or view the certificates under:
Certificates (Local computer)
    Personal
        Certificates

If you do not have a Sever Authenticating certificate consult your certicate administrator.  If you have a microsoft Certificate server you may be abel to request a certificate using the web certificate template from HTTPS://<MyDomainCertificateServer>/certsrv

Once the certificate is installed type the following to configure WINRM to listen on HTTPS:

winrm quickconfig -transport:https

 If you do not have an appropriate certificate you can run the following with the authentication methods configured for WinRM however the data will not be encrypted.

winrm quickconfig

