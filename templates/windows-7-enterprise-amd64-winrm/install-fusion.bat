REM Not much here yet, some notes to make things going
REM Enable autorun
REM reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Cdrom\Autorun /v Data /t REG_DWORD /f /d 1

REM Install vmware tools
REM /Applications/VMware\ Fusion.app/Contents/Library/vmrun installtools /Users/patrick/Documents/Virtual\ Machines.localized/win7.vmwarevm/win7.vmx


REM Manually install it
REM http://communities.vmware.com/servlet/JiveServlet/previewBody/12413-102-4-13370/VMware%20Tools%20-%20Unattended_Install.pdf

REM NOT WORKING
REM msiexec /i "VMware Tools.msi" ADDLOCAL=ALL REMOVE="Hgfs,WYSE,GuestSDK,vmdesched" /qn /l* C:\temp\toolsinst.log /norestart
REM VMware Tools64.msi for 64 bit

REM WORKING
REM d:Setup64.exe /s /v "/qn"
REM 
