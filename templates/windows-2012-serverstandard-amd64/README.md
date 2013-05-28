Microsoft Windows Server 2012 Veewee Definition
-----------------------------------------------

You can download a free trial of Windows Server 2012 from Microsoft:

* url: http://technet.microsoft.com/en-us/evalcenter/hh670538.aspx

Place it in a directory called "iso".

The installation uses the standard way for Windows Unattended installation. The XML file was created using the Windows ADK (Automated Deployment Kit), but it can also be edited by hand.

To edit the Autounattend.xml and validate it:

Download The Windows® Automated Deployment Kit (ADK) for Windows® 8:

* url: http://www.microsoft.com/en-us/download/details.aspx?id=30652

Building the machine creates a floppy that contains:
  - Autounattend.xml (that will configure the windows)
  - oracle-cert.cer (certificate for VirtualBox tools)

AIK also includes dism, which will allow you to choose a specific flavor of Windows 2012 to install. By default, this definition installs Server Standard.

If you want to install a different version, edit Autounattend.xml and replace the /IMAGE/NAME value with one of the names listed in the 2012 install.wim on the install DVD ISO.

```xml
<InstallFrom>
  <MetaData wcm:action="add">
    <Key>/IMAGE/NAME</Key>
    <Value>Windows Server 2012 SERVERSTANDARD</Value>
  </MetaData>
</InstallFrom>
```

```
PS C:\Users\Administrator> Dism /Get-WIMInfo /WimFile:D:\sources\install.wim

Deployment Image Servicing and Management tool
Version: 6.2.9200.16384

Details for image : D:\sources\install.wim

Index : 1
Name : Windows Server 2012 SERVERSTANDARDCORE
Description : Windows Server 2012 SERVERSTANDARDCORE
Size : 7,182,564,199 bytes

Index : 2
Name : Windows Server 2012 SERVERSTANDARD
Description : Windows Server 2012 SERVERSTANDARD
Size : 12,002,145,363 bytes

Index : 3
Name : Windows Server 2012 SERVERDATACENTERCORE
Description : Windows Server 2012 SERVERDATACENTERCORE
Size : 7,177,138,892 bytes

Index : 4
Name : Windows Server 2012 SERVERDATACENTER
Description : Windows Server 2012 SERVERDATACENTER
Size : 11,997,664,663 bytes

The operation completed successfully.
```

You will also need to change the KMS Client Setup key in the Autounattend.xml for the flavor you want:

* url: http://technet.microsoft.com/en-us/library/jj612867.aspx
