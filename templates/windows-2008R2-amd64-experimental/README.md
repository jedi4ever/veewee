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
$ ssh -p 7222 -L5985:localhost:5985 vagrant@localhost
$ gem install chef
$ gem install knife-windows
$ knife bootstrap windows winrm localhost -x Administrator -P 'vagrant'
</pre>
