# This is a branch to allows windows VM's to be used via winrm and not relying on ssh.

-------


- veewee vbox define windows-7-enterprise-amd64-winrm windows-7-enterprise-amd64-winrm
- veewee vbox build windows-7-enterprise-amd64-winrm


```
chris@chris-MacBookAir:~/vagrant$ veewee vbox define windows-7-enterprise-amd64-winrm windows-7-enterprise-amd64-winrm
The basebox 'windows-7-enterprise-amd64-winrm' has been succesfully created from the template 'windows-7-enterprise-amd64-winrm'
You can now edit the definition files stored in definitions/windows-7-enterprise-amd64-winrm or build the box with:
veewee vbox build 'windows-7-enterprise-amd64-winrm'
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
Veewee03 will bring many new features:

- kvm and vmware fusion support -
- veewee as a standalone tool tool if you don't use virtualbox,vagrant 
- postinstall scripts can now be toggle with --include and --exclude

Caveat: it's alpha-functional but not as polished as the previous version. But I'm sure with your help this won't take long.

My apologies for all the pull-requests to the previous version that will not be merged automatically. I'm focusing more on get this version stable and will incorporate the ideas later (some already are)

---
**VeeWee:** the tool to easily build vagrant base boxes or kvm,virtualbox and fusion images

Vagrant is a great tool to test new things or changes in a virtual machine(Virtualbox) using either chef or puppet.
The first step is to download an existing 'base box'. I believe this scares a lot of people as they don't know who or how this box was build. Therefore lots of people end up first building their own base box to use with vagrant.

Besides building Vagrant boxes, veewee can also be used for:

- create vmware (fusion), kvm  virtual machines 
- interact with with those vms (up, destroy, halt, ssh)
- export them : OVA for fusion, IMG for KVM and ovf for virtualbox

Before you start read through:

- the [requirements](veewee/tree/master/doc/requirements.md)
- the [installation](veewee/tree/master/doc/installation.md) procedure

Depending on how you want to use veewee, read through one of the following guides: (**work in progres**)

- [guide for vagrant](veewee/tree/master/doc/vagrant.md)

- [guide for Virtualbox](veewee/tree/master/doc/vbox.md)
- [guide for Vmware fusion](veewee/tree/master/doc/fusion.md)
- [guide for KVM](veewee/tree/master/doc/kvm.md)

You can also look at the more detailed pages on each subject in the [documentation directory](veewee/tree/master/doc)

People have reported good experiences, why don't you give it a try?

## If you have a setup working, share your 'definition' with me. That would be fun! 

IDEAS:

- Now you integrate this with your CI build to create a daily basebox
