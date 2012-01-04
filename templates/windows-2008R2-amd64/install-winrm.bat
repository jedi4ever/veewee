cmd /c winrm quickconfig -q
cmd /c winrm quickconfig -transport:https
cmd /c winrm set winrm/config/winrs @{MaxMemoryPerShellMB="300"}
cmd /c winrm set winrm/config/service @{AllowUnencrypted="true"}
cmd /c winrm set winrm/config/service/auth @{Basic="true"}
cmd /c netsh advfirewall firewall set rule group="remote administration" new enable=yes
cmd /c netsh advfirewall firewall set rule group="network discovery" new enable=yes
; cmd /c net use x: \\vboxsrv\sharename
