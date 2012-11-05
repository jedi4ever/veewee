module Veewee
  module Provider
    module Core
      module Helper

        module Comm

          def comm_method
            if (definition.winrm_user && definition.winrm_password)
              :winrm
            else
              :ssh
            end
          end

          def when_comm_login_works(ip="127.0.0.1", options = {  } , &block)
            case comm_method
            when :winrm
              when_winrm_login_works(ip,options,block)
            when :ssh
              when_ssh_login_works(ip,options,block)
            end
          end

          def comm_transfer_file(host,filename,destination = '.' , options = {})
            case comm_method
            when :winrm
              winrm_transfer_file(host,filename,destination,options)
            when :ssh
              ssh_transfer_file(host,filename,destination,options)
            end
          end

          def comm_execute(host,command, options = { :progress => "on"} )
            case comm_method
            when :winrm
              winrm_execute(host,command, options )
            when :ssh
              ssh_execute(host,command, options )
            end
          end

        end #Class
      end #Module
    end #Module
  end #Module
end #Module
