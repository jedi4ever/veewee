# with this, we can open the iso, and extract the VBoxWindowsAdditions.exe!
# http://downloads.sourceforge.net/sevenzip/7z920.exe
cmd /c certutil -addstore -f "TrustedPublisher" a:oracle-cert.cer
cmd /c c:\cygwin\bin\wget https://s3-ap-southeast-1.amazonaws.com/vboxfan/4.1.8/VBoxWindowsAdditions-amd64.exe --no-check-certificate
cmd /c .\VBoxWindowsAdditions-amd64.exe /S
