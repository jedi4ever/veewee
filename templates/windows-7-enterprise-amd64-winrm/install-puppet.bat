cmd /C cscript %TEMP%\wget.vbs /url:https://downloads.puppetlabs.com/windows/puppet-3.0.1.msi /path:%TEMP%\puppet.msi
cmd /C msiexec /qn /i %TEMP%\puppet.msi
