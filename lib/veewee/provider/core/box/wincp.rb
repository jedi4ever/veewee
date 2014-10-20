require 'to_slug'
require 'veewee/provider/core/helper/winrm'

module Veewee
  module Provider
    module  Core
      module BoxCommand

        def wincp(localfile,remotefile,options={})
          raise Veewee::Error,"Box is not running" unless self.running?

          if self.exec("cmd.exe /C dir #{wget_vbs_file} > NUL",{:exitcode=>"*"}).status != 0
            env.ui.warn "Creating wget.vbs"
            create_wget_vbs_command do |command_chunk, chunk_num|
              self.exec(%Q!cmd.exe /C echo "Rendering #{wget_vbs_file} chunk #{chunk_num}" && #{command_chunk}!)
            end
          end

          # Calculate an available kickstart port which we will use for wincp
          definition.kickstart_port = "7000" if definition.kickstart_port.nil?
          guessed_port=guess_free_port(definition.kickstart_port.to_i,7199).to_s
          if guessed_port.to_s!=definition.kickstart_port
            env.ui.warn "Changing wincp port from #{definition.kickstart_port} to #{guessed_port}"
            definition.kickstart_port=guessed_port.to_s
          end

          urlpath = localfile.to_slug
          urlpath = urlpath.start_with?('/') ? urlpath : '/' + urlpath

          begin
            self.when_winrm_login_works(self.ip_address,winrm_options.merge(options)) do
              env.ui.warn "Spinning up an allow_for_http_request on http://#{host_ip_as_seen_by_guest}:#{definition.kickstart_port}#{localfile} at URL #{urlpath}"
              allow_for_http_request(
                  localfile,
                  urlpath,
                  {
                    :port => definition.kickstart_port,
                    :timeout => 300,
                  }
              )

              env.ui.info "Going to try and copy #{localfile} to #{remotefile.inspect}"
              self.exec("cmd.exe /C cscript %TEMP%\\wget.vbs /url:http://#{host_ip_as_seen_by_guest}:#{definition.kickstart_port}#{urlpath} /path:#{remotefile}")
              # while true do
              #   sleep 0.1 # used to debug
              # end
            end
          end
        end


        def wget_vbs_file
          "%TEMP%\\\\wget.vbs"
        end

        def create_wget_vbs_command(&block)
          bootstrap_bat = []
          chunk_num = 0
          wget_vbs.each_line do |line|
            # escape WIN BATCH special chars
            line.gsub!(/[(<|>)^]/).each{|m| "^#{m}"}
            # windows commands are limited to 2047 characters
            if((bootstrap_bat + [line]).join(" && ").size > 2047 )
              yield bootstrap_bat.join(" && "), chunk_num += 1
              bootstrap_bat = []
            end
            bootstrap_bat << ">> #{wget_vbs_file} (echo.#{line.chomp.strip})"
          end
          yield bootstrap_bat.join(" && "), chunk_num += 1
          bootstrap_bat = []
        end

        def wget_vbs
          wget_vbs = <<-WGET
url = WScript.Arguments.Named("url")
path = WScript.Arguments.Named("path")
Set objXMLHTTP = CreateObject("MSXML2.ServerXMLHTTP")
Set wshShell = CreateObject( "WScript.Shell" )
Set objUserVariables = wshShell.Environment("USER")

rem http proxy is optional
rem attempt to read from HTTP_PROXY env var first
On Error Resume Next

If NOT (objUserVariables("HTTP_PROXY") = "") Then
objXMLHTTP.setProxy 2, objUserVariables("HTTP_PROXY")

rem fall back to named arg
ElseIf NOT (WScript.Arguments.Named("proxy") = "") Then
objXMLHTTP.setProxy 2, WScript.Arguments.Named("proxy")
End If

On Error Goto 0

objXMLHTTP.open "GET", url, false
objXMLHTTP.send()
If objXMLHTTP.Status = 200 Then
Set objADOStream = CreateObject("ADODB.Stream")
objADOStream.Open
objADOStream.Type = 1
objADOStream.Write objXMLHTTP.ResponseBody
objADOStream.Position = 0
Set objFSO = Createobject("Scripting.FileSystemObject")
If objFSO.Fileexists(path) Then objFSO.DeleteFile path
Set objFSO = Nothing
objADOStream.SaveToFile path
objADOStream.Close
Set objADOStream = Nothing
End if
Set objXMLHTTP = Nothing
WGET
          #escape_and_echo(win_wget)
          wget_vbs
        end

        # escape WIN BATCH special chars
        # and prefixes each line with an
        # echo
        def escape_and_echo(file_contents)
          file_contents.gsub(/^(.*)$/, 'echo.\1').gsub(/([(<|>)^])/, '^\1')
        end

      end # Module
    end # Module
  end # Module
end # Module
