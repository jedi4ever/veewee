This uses the All In One "Windows 7 7600 AIO.ISO" from MSDN
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
#         <Value>Windows 7 ULTIMATE</Value>
#     </MetaData>
# </InstallFrom>


