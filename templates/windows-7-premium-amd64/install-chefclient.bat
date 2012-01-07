mkdir C:\chef

> C:\chef\wget.vbs (
echo.url = WScript.Arguments.Named^("url"^)
echo.path = WScript.Arguments.Named^("path"^)
echo.Set objXMLHTTP = CreateObject^("MSXML2.ServerXMLHTTP"^)
echo.Set wshShell = CreateObject^( "WScript.Shell" ^)
echo.Set objUserVariables = wshShell.Environment^("USER"^)
echo.
echo.'http proxy is optional
echo.'attempt to read from HTTP_PROXY env var first
echo.On Error Resume Next
echo.
echo.If NOT ^(objUserVariables^("HTTP_PROXY"^) = ""^) Then
echo.objXMLHTTP.setProxy 2, objUserVariables^("HTTP_PROXY"^)
echo.
echo.'fall back to named arg
echo.ElseIf NOT ^(WScript.Arguments.Named^("proxy"^) = ""^) Then
echo.objXMLHTTP.setProxy 2, WScript.Arguments.Named^("proxy"^)
echo.End If
echo.
echo.On Error Goto 0
echo.
echo.objXMLHTTP.open "GET", url, false
echo.objXMLHTTP.send^(^)
echo.If objXMLHTTP.Status = 200 Then
echo.Set objADOStream = CreateObject^("ADODB.Stream"^)
echo.objADOStream.Open
echo.objADOStream.Type = 1
echo.objADOStream.Write objXMLHTTP.ResponseBody
echo.objADOStream.Position = 0
echo.Set objFSO = Createobject^("Scripting.FileSystemObject"^)
echo.If objFSO.Fileexists^(path^) Then objFSO.DeleteFile path
echo.Set objFSO = Nothing
echo.objADOStream.SaveToFile path
echo.objADOStream.Close
echo.Set objADOStream = Nothing
echo.End if
echo.Set objXMLHTTP = Nothing
)

@rem Install Chef using chef-client MSI installer
cscript /nologo C:\chef\wget.vbs /url:http://www.opscode.com/chef/install.msi /path:%TEMP%\chef-client-latest.msi
msiexec /qb /i %TEMP%\chef-client-latest.msi
