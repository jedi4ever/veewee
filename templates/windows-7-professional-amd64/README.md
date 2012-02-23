You can download a free trial of Windows 7 Enterprise 90-day Trial

url: http://technet.microsoft.com/en-us/evalcenter/cc442495.aspx
file: 7600.16385.090713-1255_x64fre_enterprise_en-us_EVAL_Eval_Enterprise-GRMCENXEVAL_EN_DVD.iso
md5sum: 1d0d239a252cb53e466d39e752b17c28  

'''
PS C:\Users\Administrator> Dism /Get-WIMInfo /WimFile:d:\sources\install.wim

Deployment Image Servicing and Management tool
Version: 6.1.7600.16385

Details for image : d:\sources\install.wim

Index : 1
Name : Windows 7 ENTERPRISE
Description : Windows 7 ENTERPRISE
Size : 11,913,037,777 bytes

The operation completed successfully.
'''


Though I have also used "Windows 7 7600 AIO.ISO" from MSDN
* All In One = AIO
file: Windows 7 7600 AIO.ISO
md5sum: ace6c61269613bf515fd59c62185bbcf


'''
PS C:\Users\Administrator> Dism /Get-WIMInfo /WimFile:d:\sources\install.wim

Deployment Image Servicing and Management tool
Version: 6.1.7600.16385

Details for image : d:\sources\install.wim

Index : 1
Name : Windows 7 STARTER
Description : Windows 7 STARTER
Size : 7,936,340,784 bytes

Index : 2
Name : Windows 7 HOMEBASIC
Description : Windows 7 HOMEBASIC
Size : 7,992,394,907 bytes

Index : 3
Name : Windows 7 HOMEPREMIUM
Description : Windows 7 HOMEPREMIUM
Size : 8,432,859,356 bytes

Index : 4
Name : Windows 7 PROFESSIONAL
Description : Windows 7 PROFESSIONAL
Size : 8,313,318,889 bytes

Index : 5
Name : Windows 7 ULTIMATE
Description : Windows 7 ULTIMATE
Size : 8,471,060,645 bytes

Index : 6
Name : Windows 7 Home Basic X64
Description : Windows 7 HOMEBASIC
Size : 11,500,789,302 bytes

Index : 7
Name : Windows 7 Home Premium X64
Description : Windows 7 HOMEPREMIUM
Size : 12,012,660,212 bytes

Index : 8
Name : Windows 7 Home Professional X64
Description : Windows 7 PROFESSIONAL
Size : 11,910,752,928 bytes

Index : 9
Name : Windows 7 Home Ultimate X64
Description : Windows 7 ULTIMATE
Size : 12,070,211,908 bytes

The operation completed successfully.
'''

- place it in a directory called iso

The installation uses the Standard way for Windows Unattended installation. The XML file was created using the Windows AIK kit, but the file can also be edited by hand.

To edit the Autounattend.xml and validate it:
You can download The Windows® Automated Installation Kit (AIK) for Windows® 7:
url: http://www.microsoft.com/download/en/details.aspx?id=5753
file: KB3AIK_EN.iso
md5sum: 1e73b24a89eceab9d50585b92db5482f



- Building the machine creates a floppy that contains:
  - AutoUnattend.xml (that will configure the windows)
  - winrm-install.bat (activates the http and https listener + punches the firewall hole)

AIK also includes dism, which will allow you to choose a specific version:

If you want to install a different version, edit Autoattended.xml and replace the /IMAGE/NAME value with
one of the names listed in the sources/install.wim on the install DVD .iso

                    # <InstallFrom>
                    #     <MetaData wcm:action="add">
                    #         <Key>/IMAGE/NAME</Key>
                    #         <Value>Windows Server 2008 R2 SERVERSTANDARD</Value>
                    #     </MetaData>
                    # </InstallFrom>


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

