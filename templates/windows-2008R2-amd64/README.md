You can download a free trial of Windows 2008 R2

My downloaded iso was named '7601.17514.101119-1850_x64fre_server_eval_en-us-GRMSXEVAL_EN_DVD.iso'

- place it in a directory called iso

The installation uses the Standard way for Windows Unattended installation. The XML file was created using the Windows AIK kit, but the file can also be edited by hand.

- Building the machine creates a floppy that contains:
  - AutoUnattend.xml (that will configure the windows)
  - cygwin-setup.exe (the standard setup.exe cygwin binaries)
  - cygwin-install.bat (this script will run the cygwin installer + get sshd/openssl going)
  - winrm-install.bat (activates the http and https listener + punches the firewall hole)

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
