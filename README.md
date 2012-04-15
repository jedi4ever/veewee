# This is a branch that allows windows VM's to be used via winrm and not relying on ssh.

-------


- veewee vbox define windows-7-enterprise-amd64-winrm windows-7-enterprise-amd64-winrm
- veewee vbox build windows-7-enterprise-amd64-winrm
- veewee vbox winrm windows-7-enterprise-amd64-winrm 'hostname'
- veewee vbox copy windows-7-enterprise-amd64-winrm sourcefile.txt destfileinVM.txt


Winrm allows us to execute commands on the windows host, but it lacks a file transfer method similar to scp.

If winrm_user or winrm_password are in the definition, vbox will use wincp.

wincp: https://github.com/hh/veewee/blob/feature/windows/lib/veewee/provider/core/box/wincp.rb#L11

However the wincp implementation currently does nothing.


I'm open to thoughts on how to implement wincp / winrm copy.



Current thought:

handle_kickstart: https://github.com/hh/veewee/blob/feature/windows/lib/veewee/provider/core/box/build.rb#L185

In handle_kickstart we open up an http listener and serve up the files and they are retrieved by the host.


```
chris@chris-MacBookAir:~/vagrant$ veewee vbox define windows-7-enterprise-amd64-winrm windows-7-enterprise-amd64-winrm
The basebox 'windows-7-enterprise-amd64-winrm' has been succesfully created from the template 'windows-7-enterprise-amd64-winrm'
You can now edit the definition files stored in definitions/windows-7-enterprise-amd64-winrm or build the box with:
veewee vbox build 'windows-7-enterprise-amd64-winrm'
```

```
chris@chris-MacBookAir:~/vagrant$ veewee vbox build 'windows-7-enterprise-amd64-winrm'
Downloading vbox guest additions iso v 4.1.12 - http://download.virtualbox.org/virtualbox/4.1.12/VBoxGuestAdditions_4.1.12.iso
Checking if isofile VBoxGuestAdditions_4.1.12.iso already exists.
Full path: /home/chris/vagrant/iso/VBoxGuestAdditions_4.1.12.iso

The isofile VBoxGuestAdditions_4.1.12.iso already exists.
Building Box windows-7-enterprise-amd64-winrm with Definition windows-7-enterprise-amd64-winrm:
- postinstall_include : []
- postinstall_exclude : []

The isofile 7600.16385.090713-1255_x64fre_enterprise_en-us_EVAL_Eval_Enterprise-GRMCENXEVAL_EN_DVD.iso already exists.
Creating vm windows-7-enterprise-amd64-winrm : 512M - 1 CPU - Windows7_64
Creating new harddrive of size 20280 
Mounting cdrom: /home/chris/vagrant/iso/7600.16385.090713-1255_x64fre_enterprise_en-us_EVAL_Eval_Enterprise-GRMCENXEVAL_EN_DVD.iso
Mounting guest additions: /home/chris/vagrant/iso/VBoxGuestAdditions_4.1.12.iso
Attaching disk: /home/chris/VirtualBox VMs/windows-7-enterprise-amd64-winrm/windows-7-enterprise-amd64-winrm.vdi
Using winrm because winrm_user and winrm_password are both set
Received port hint - 5985
Found port 5985 available
Received port hint - 5985
Found port 5985 available
Waiting 0 seconds for the machine to boot

Done typing.

Skipping webserver as no kickstartfile was specified
Starting a webserver :
Waiting for winrm login on 127.0.0.1 with user vagrant to windows on port => 5985 to work, timeout=10000 sec
.......................................................................................................................................................................................................................
Going to try and copy /tmp/.veewee_version20120416-20165-sog9s to .veewee_version
However File copy via WINRM not implemented yet, look at core/helper/scp
Maybe we should start up a web server and execute a retrieve?

Waiting for winrm login on 127.0.0.1 with user vagrant to windows on port => 5985 to work, timeout=10000 sec
.
Going to try and copy /tmp/.vbox_version20120416-20165-bnf69s to .vbox_version
However File copy via WINRM not implemented yet, look at core/helper/scp
Maybe we should start up a web server and execute a retrieve?

Waiting for winrm login on 127.0.0.1 with user vagrant to windows on port => 5985 to work, timeout=10000 sec
.
Going to try and copy /home/chris/vagrant/definitions/windows-7-enterprise-amd64-winrm/postinstall.sh to postinstall.sh
However File copy via WINRM not implemented yet, look at core/helper/scp
Maybe we should start up a web server and execute a retrieve?

WINRM EXEC NOT IMPLEMPENTED YET
Command: postinstall.sh
The box windows-7-enterprise-amd64-winrm was build succesfully!
You can now login to the box with:
knife winrm -m 127.0.0.1-P 5985 -x vagrant -P vagrant COMMAND
```

```
chris@chris-MacBookAir:~/telogis/vagrant$ veewee vbox winrm windows-7-enterprise-amd64-winrm 'hostname'
Executing winrm command: hostname
vagrant-2008R2
```

```
chris@chris-MacBookAir:~/telogis/vagrant$ veewee vbox copy windows-7-enterprise-amd64-winrm sourcefile.txt destfileinVM.txt
Waiting for winrm login on 127.0.0.1 with user vagrant to windows on port => 5985 to work, timeout=10000 sec
.
Going to try and copy sourcefile.txt to destfileinVM.txt
However File copy via WINRM not implemented yet, look at core/helper/scp
Maybe we should start up a web server and execute a retrieve?

```

