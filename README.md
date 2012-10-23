# This is a branch that allows windows VM's to be used via winrm and not relying on ssh.

-------


- veewee vbox define windows-7-enterprise-amd64-winrm windows-7-enterprise-amd64-winrm
- veewee vbox build windows-7-enterprise-amd64-winrm
- veewee vbox winrm windows-7-enterprise-amd64-winrm 'hostname'
- veewee vbox copy windows-7-enterprise-amd64-winrm sourcefile.txt destfileinVM.txt
- veewee vbox copy windows-7-enterprise-amd64-winrm sourcefile.txt destfileinVM.txt
- vagrant basebox export windows-7-enterprise-amd64-winrm
- vagrant box add 'windows-7-enterprise-amd64-winrm' 'windows-7-enterprise-amd64-winrm.box'
- vagrant init windows-7-enterprise-amd64-winrm

```
$ veewee vbox define windows-7-enterprise-amd64-winrm windows-7-enterprise-amd64-winrm

The basebox 'windows-7-enterprise-amd64-winrm' has been succesfully created from the template 'windows-7-enterprise-amd64-winrm'
You can now edit the definition files stored in definitions/windows-7-enterprise-amd64-winrm or build the box with:
veewee vbox build 'windows-7-enterprise-amd64-winrm'
```

```
$ veewee vbox build windows-7-enterprise-amd64-winrm --force
Downloading vbox guest additions iso v 4.1.12 - http://download.virtualbox.org/virtualbox/4.1.12/VBoxGuestAdditions_4.1.12.iso
Checking if isofile VBoxGuestAdditions_4.1.12.iso already exists.
Full path: /home/hh/chef/veewee/iso/VBoxGuestAdditions_4.1.12.iso

The isofile VBoxGuestAdditions_4.1.12.iso already exists.
Building Box windows-7-enterprise-amd64-winrm with Definition windows-7-enterprise-amd64-winrm:
- postinstall_include : []
- postinstall_exclude : []
- force : true

The isofile 7600.16385.090713-1255_x64fre_enterprise_en-us_EVAL_Eval_Enterprise-GRMCENXEVAL_EN_DVD.iso already exists.
VBoxManage unregistervm  'windows-7-enterprise-amd64-winrm' --delete
Deleting vm windows-7-enterprise-amd64-winrm
Creating vm windows-7-enterprise-amd64-winrm : 512M - 1 CPU - Windows7_64
Creating new harddrive of size 20280 
Mounting cdrom: /home/hh/chef/veewee/iso/7600.16385.090713-1255_x64fre_enterprise_en-us_EVAL_Eval_Enterprise-GRMCENXEVAL_EN_DVD.iso
Mounting guest additions: /home/hh/chef/veewee/iso/VBoxGuestAdditions_4.1.12.iso
Attaching disk: /home/hh/VirtualBox VMs/windows-7-enterprise-amd64-winrm/windows-7-enterprise-amd64-winrm.vdi
Using winrm because winrm_user and winrm_password are both set
Received port hint - 5985
Found port 5985 available
Received port hint - 5985
Found port 5985 available
Waiting 0 seconds for the machine to boot

Done typing.

Skipping webserver as no kickstartfile was specified
Received port hint - 7000
Found port 7000 available
Waiting for winrm login on 127.0.0.1 with user vagrant to windows on port => 5986 to work, timeout=10000 sec
........................
Executing winrm command: cmd.exe /C dir %TEMP%\\wget.vbs > %TEMP%\null
File Not Found
Creating wget.vbs
Executing winrm command: cmd.exe /C echo "Rendering '%TEMP%\\wget.vbs' chunk 1" && >> %TEMP%\\wget.vbs (echo.url = WScript.Arguments.Named^("url"^)) && >> %TEMP%\\wget.vbs (echo.path = WScript.Arguments.Named^("path"^)) && >> %TEMP%\\wget.vbs (echo.Set objXMLHTTP = CreateObject^("MSXML2.ServerXMLHTTP"^)) && >> %TEMP%\\wget.vbs (echo.Set wshShell = CreateObject^( "WScript.Shell" ^)) && >> %TEMP%\\wget.vbs (echo.Set objUserVariables = wshShell.Environment^("USER"^)) && >> %TEMP%\\wget.vbs (echo.) && >> %TEMP%\\wget.vbs (echo.'http proxy is optional) && >> %TEMP%\\wget.vbs (echo.'attempt to read from HTTP_PROXY env var first) && >> %TEMP%\\wget.vbs (echo.On Error Resume Next) && >> %TEMP%\\wget.vbs (echo.) && >> %TEMP%\\wget.vbs (echo.If NOT ^(objUserVariables^("HTTP_PROXY"^) = ""^) Then) && >> %TEMP%\\wget.vbs (echo.objXMLHTTP.setProxy 2, objUserVariables^("HTTP_PROXY"^)) && >> %TEMP%\\wget.vbs (echo.) && >> %TEMP%\\wget.vbs (echo.'fall back to named arg) && >> %TEMP%\\wget.vbs (echo.ElseIf NOT ^(WScript.Arguments.Named^("proxy"^) = ""^) Then) && >> %TEMP%\\wget.vbs (echo.objXMLHTTP.setProxy 2, WScript.Arguments.Named^("proxy"^)) && >> %TEMP%\\wget.vbs (echo.End If) && >> %TEMP%\\wget.vbs (echo.) && >> %TEMP%\\wget.vbs (echo.On Error Goto 0) && >> %TEMP%\\wget.vbs (echo.) && >> %TEMP%\\wget.vbs (echo.objXMLHTTP.open "GET", url, false) && >> %TEMP%\\wget.vbs (echo.objXMLHTTP.send^(^)) && >> %TEMP%\\wget.vbs (echo.If objXMLHTTP.Status = 200 Then) && >> %TEMP%\\wget.vbs (echo.Set objADOStream = CreateObject^("ADODB.Stream"^)) && >> %TEMP%\\wget.vbs (echo.objADOStream.Open) && >> %TEMP%\\wget.vbs (echo.objADOStream.Type = 1) && >> %TEMP%\\wget.vbs (echo.objADOStream.Write objXMLHTTP.ResponseBody) && >> %TEMP%\\wget.vbs (echo.objADOStream.Position = 0) && >> %TEMP%\\wget.vbs (echo.Set objFSO = Createobject^("Scripting.FileSystemObject"^)) && >> %TEMP%\\wget.vbs (echo.If objFSO.Fileexists^(path^) Then objFSO.DeleteFile path) && >> %TEMP%\\wget.vbs (echo.Set objFSO = Nothing) && >> %TEMP%\\wget.vbs (echo.objADOStream.SaveToFile path) && >> %TEMP%\\wget.vbs (echo.objADOStream.Close)
"Rendering 'C:\Users\vagrant\AppData\Local\Temp\\wget.vbs' chunk 1" 
Executing winrm command: cmd.exe /C echo "Rendering '%TEMP%\\wget.vbs' chunk 2" && >> %TEMP%\\wget.vbs (echo.Set objADOStream = Nothing) && >> %TEMP%\\wget.vbs (echo.End if) && >> %TEMP%\\wget.vbs (echo.Set objXMLHTTP = Nothing)
"Rendering 'C:\Users\vagrant\AppData\Local\Temp\\wget.vbs' chunk 2" 
Spinning up a wait_for_http_request on http://10.0.2.2:7000//tmp/.veewee_version20121022-9183-15gv13c
Going to try and copy /tmp/.veewee_version20121022-9183-15gv13c to ".veewee_version"
Executing winrm command: cmd.exe /C cscript %TEMP%\wget.vbs /url:http://10.0.2.2:7000/tmp/.veewee_version20121022-9183-15gv13c /path:.veewee_version
Serving file /tmp/.veewee_version20121022-9183-15gv13c
Microsoft (R) Windows Script Host Version 5.8
Copyright (C) Microsoft Corporation. All rights reserved.

Received port hint - 7000
Found port 7001 available
Changing wincp port from 7000 to 7001
Executing winrm command: cmd.exe /C dir %TEMP%\\wget.vbs > %TEMP%\null
Spinning up a wait_for_http_request on http://10.0.2.2:7001//tmp/.vbox_version20121022-9183-1guel7e
Going to try and copy /tmp/.vbox_version20121022-9183-1guel7e to ".vbox_version"
Executing winrm command: cmd.exe /C cscript %TEMP%\wget.vbs /url:http://10.0.2.2:7001/tmp/.vbox_version20121022-9183-1guel7e /path:.vbox_version
Serving file /tmp/.vbox_version20121022-9183-1guel7e
Microsoft (R) Windows Script Host Version 5.8
Copyright (C) Microsoft Corporation. All rights reserved.

Received port hint - 7001
Found port 7002 available
Changing wincp port from 7001 to 7002
Executing winrm command: cmd.exe /C dir %TEMP%\\wget.vbs > %TEMP%\null
Spinning up a wait_for_http_request on http://10.0.2.2:7002//home/hh/chef/veewee/definitions/windows-7-enterprise-amd64-winrm/install-chef.bat
Going to try and copy /home/hh/chef/veewee/definitions/windows-7-enterprise-amd64-winrm/install-chef.bat to "install-chef.bat"
Executing winrm command: cmd.exe /C cscript %TEMP%\wget.vbs /url:http://10.0.2.2:7002/home/hh/chef/veewee/definitions/windows-7-enterprise-amd64-winrm/install-chef.bat /path:install-chef.bat
Serving file /home/hh/chef/veewee/definitions/windows-7-enterprise-amd64-winrm/install-chef.bat
Microsoft (R) Windows Script Host Version 5.8
Copyright (C) Microsoft Corporation. All rights reserved.

Executing winrm command: install-chef.bat

C:\Users\vagrant>cmd /C cscript C:\Users\vagrant\AppData\Local\Temp\wget.vbs /url:http://www.opscode.com/chef/install.msi /path:C:\Users\vagrant\AppData\Local\Temp\chef-client.msi 
Microsoft (R) Windows Script Host Version 5.8
Copyright (C) Microsoft Corporation. All rights reserved.


C:\Users\vagrant>cmd /C msiexec /qn /i C:\Users\vagrant\AppData\Local\Temp\chef-client.msi 
The box windows-7-enterprise-amd64-winrm was build succesfully!
You can now login to the box with:
knife winrm -m 127.0.0.1 -P 5986 -x vagrant -P vagrant COMMAND
```

```
$ veewee vbox winrm windows-7-enterprise-amd64-winrm hostname
Executing winrm command: hostname
vagrant-win7ent
```

```
$ veewee vbox winrm windows-7-enterprise-amd64-winrm 'dir %TEMP%'
Executing winrm command: dir %TEMP%
 Volume in drive C is Windows 7 Enterprise
 Volume Serial Number is 58F7-01E9

 Directory of C:\Users\vagrant\AppData\Local\Temp

10/22/2012  11:26 PM    <DIR>          .
10/22/2012  11:26 PM    <DIR>          ..
10/22/2012  11:26 PM        63,636,395 chef-client.msi
10/22/2012  11:25 PM                 0 FXSAPIDebugLogFile.txt
10/22/2012  11:24 PM    <DIR>          Low
10/22/2012  11:25 PM               283 null
10/22/2012  11:24 PM            49,208 vagrant.bmp
10/22/2012  11:24 PM             1,105 wget.vbs
10/22/2012  11:25 PM               843 wmsetup.log
10/22/2012  11:25 PM    <DIR>          WPDNSE
               6 File(s)     63,687,834 bytes
               4 Dir(s)   1,431,273,472 bytes free
```

```
$ veewee vbox winrm windows-7-enterprise-amd64-winrm 'dir'
Executing winrm command: dir
 Volume in drive C is Windows 7 Enterprise
 Volume Serial Number is 58F7-01E9

 Directory of C:\Users\vagrant

10/22/2012  11:25 PM    <DIR>          .
10/22/2012  11:25 PM    <DIR>          ..
10/22/2012  11:25 PM                 7 .vbox_version
10/22/2012  11:24 PM                13 .veewee_version
10/22/2012  11:25 PM    <DIR>          Contacts
10/22/2012  11:25 PM    <DIR>          Desktop
10/22/2012  11:25 PM    <DIR>          Documents
10/22/2012  11:25 PM    <DIR>          Downloads
10/22/2012  11:25 PM    <DIR>          Favorites
10/22/2012  11:25 PM               150 install-chef.bat
10/22/2012  11:25 PM    <DIR>          Links
10/22/2012  11:25 PM    <DIR>          Music
10/22/2012  11:25 PM    <DIR>          Pictures
10/22/2012  11:25 PM    <DIR>          Saved Games
10/22/2012  11:25 PM    <DIR>          Searches
10/22/2012  11:25 PM    <DIR>          Videos
               3 File(s)            170 bytes
              13 Dir(s)   1,431,273,472 bytes free
```

```
$ vagrant basebox export windows-7-enterprise-amd64-winrm --force
[vagrant] Vagrant requires the box to be shutdown, before it can export
[vagrant] Sudo also needs to work for user 
[vagrant] Performing a clean shutdown now.
[vagrant] Waiting for winrm login on 127.0.0.1 with user vagrant to windows on port => 5986 to work, timeout=10000 sec
[vagrant] .[vagrant] 
[vagrant] Executing winrm command: shutdown /s /t 10 /c "Vagrant Shutdown" /f /d p:4:1
[vagrant] .[vagrant] .[vagrant] .[vagrant] .[vagrant] .[vagrant] .[vagrant] .[vagrant] .[vagrant] .[vagrant] .[vagrant] .[vagrant] .[vagrant] .[vagrant] .[vagrant] .[vagrant] .[vagrant] 
[vagrant] Machine windows-7-enterprise-amd64-winrm is powered off cleanly
[vagrant] Excuting vagrant voodoo:
[vagrant] vagrant package --base 'windows-7-enterprise-amd64-winrm' --output 'windows-7-enterprise-amd64-winrm.box'
[vagrant] 
[vagrant] To import it into vagrant type:
[vagrant] vagrant box add 'windows-7-enterprise-amd64-winrm' 'windows-7-enterprise-amd64-winrm.box'
[vagrant] 
[vagrant] To use it:
[vagrant] vagrant init 'windows-7-enterprise-amd64-winrm'
[vagrant] vagrant up
[vagrant] vagrant ssh
```

Now you could make windows-7-enterprise-amd64-winrm.box via an internal url and use in a Vagrantfile or

```
$ vagrant box add 'windows-7-enterprise-amd64-winrm' 'windows-7-enterprise-amd64-winrm.box
[vagrant] Downloading with Vagrant::Downloaders::File...
[vagrant] Copying box to temporary location...
[vagrant] Extracting box...
[vagrant] Verifying box...
[vagrant] Cleaning up downloaded box...
```

Obviously we have a bit of work to do to get vagrant working with winrm, but at least now we can contruct windows base boxes from scratch.