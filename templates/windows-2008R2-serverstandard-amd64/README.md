You can download a free trial of Windows Server 2008 R2 with Service Pack 1:

url: http://technet.microsoft.com/en-us/evalcenter/dd459137.aspx
url: http://msdn.microsoft.com/en-us/evalcenter/ee175713.aspx

64bit
file: 7601.17514.101119-1850_x64fre_server_eval_en-us-GRMSXEVAL_EN_DVD.iso
md5sum: 4263be2cf3c59177c45085c0a7bc6ca5  

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
one of the names listed in the 2008r2 install.wim on the install DVD .iso

                    # <InstallFrom>
                    #     <MetaData wcm:action="add">
                    #         <Key>/IMAGE/NAME</Key>
                    #         <Value>Windows Server 2008 R2 SERVERSTANDARD</Value>
                    #     </MetaData>
                    # </InstallFrom>

PS C:\Users\Administrator> Dism /Get-WIMInfo /WimFile:d:\sources\install.wim

Deployment Image Servicing and Management tool
Version: 6.1.7600.16385

Details for image : d:\sources\install.wim

Index : 1
Name : Windows Server 2008 R2 SERVERSTANDARD
Description : Windows Server 2008 R2 SERVERSTANDARD
Size : 10,510,643,622 bytes

Index : 2
Name : Windows Server 2008 R2 SERVERSTANDARDCORE
Description : Windows Server 2008 R2 SERVERSTANDARDCORE
Size : 3,564,132,307 bytes

Index : 3
Name : Windows Server 2008 R2 SERVERENTERPRISE
Description : Windows Server 2008 R2 SERVERENTERPRISE
Size : 10,511,024,733 bytes

Index : 4
Name : Windows Server 2008 R2 SERVERENTERPRISECORE
Description : Windows Server 2008 R2 SERVERENTERPRISECORE
Size : 3,564,106,331 bytes

Index : 5
Name : Windows Server 2008 R2 SERVERDATACENTER
Description : Windows Server 2008 R2 SERVERDATACENTER
Size : 10,511,131,897 bytes

Index : 6
Name : Windows Server 2008 R2 SERVERDATACENTERCORE
Description : Windows Server 2008 R2 SERVERDATACENTERCORE
Size : 3,564,144,547 bytes

Index : 7
Name : Windows Server 2008 R2 SERVERWEB
Description : Windows Server 2008 R2 SERVERWEB
Size : 10,520,222,743 bytes

Index : 8
Name : Windows Server 2008 R2 SERVERWEBCORE
Description : Windows Server 2008 R2 SERVERWEBCORE
Size : 3,562,750,400 bytes

The operation completed successfully.


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

