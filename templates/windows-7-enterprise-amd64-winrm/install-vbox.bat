cmd /c certutil -addstore -f "TrustedPublisher" a:oracle-cert.cer
cmd /c e:\VBoxWindowsAdditions-amd64.exe /S

shutdown /r /t 2 /c "Install Virtualbox Guest Additions Reboot" /f /d p:4:1
