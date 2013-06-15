@REM Loop ten times to make sure outbound networking is up
@FOR /L %%n IN (1,1,10) DO (
  @PING -n 1 downloads.puppetlabs.com
  @IF %ERRORLEVEL% == 0 CALL :wget
  @TIMEOUT 10
)

:err
@ECHO "Couldn't reach PuppetLabs even after 10 retries"
@GOTO :done

:wget
@REM Install Puppet using MSI installer
@setlocal

@set REMOTE_SOURCE_MSI_URL=https://downloads.puppetlabs.com/windows/puppet-3.2.1.msi
@set LOCAL_DESTINATION_MSI_PATH=%TEMP%\puppet-latest.msi
@set QUERY_STRING=?DownloadContext=PowerShell

@set DOWNLOAD_COMMAND=$webClient=new-object System.Net.WebClient; $webClient.DownloadFile('%REMOTE_SOURCE_MSI_URL%%QUERY_STRING%', '%LOCAL_DESTINATION_MSI_PATH%')

@if EXIST "%LOCAL_DESTINATION_MSI_PATH%" del /f /q "%LOCAL_DESTINATION_MSI_PATH%"
powershell -noprofile -noninteractive -command "%DOWNLOAD_COMMAND%"
@IF NOT ERRORLEVEL 1 (
  @ECHO Download succeeded
    ) else (
  @ECHO Failed to download %REMOTE_SOURCE_MSI_URL%
  @ECHO Subsequent attempt to install the downloaded MSI is likely to fail
)

msiexec /qn /i "%LOCAL_DESTINATION_MSI_PATH%" PUPPET_MASTER_SERVER=dummy_server

@endlocal
EXIT

:done
EXIT
