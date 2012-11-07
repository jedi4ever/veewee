cmd /C cscript %TEMP%\wget.vbs /url:https://downloads.puppetlabs.com/windows/puppet-3.0.1.msi /path:%TEMP%\puppet.msi
cmd /C msiexec /qn /i %TEMP%\puppet.msi
cmd /C gem install sys-admin win32-process win32-dir win32-taskscheduler
cmd /C gem install win32-service --platform=mswin32
