require 'veewee/provider/core/helper/winrm'
module Veewee
  module Provider
    module  Core
      module BoxCommand


        def winrm(command=nil,options={})

          raise Veewee::Error,"Box is not running" unless self.running?
          winrm_options={:user => definition.winrm_user,:password => definition.winrm_password, :port => definition.winrm_host_port, :exitcode => '*'}

          if (command.nil?)
            env.ui.info "This is a simple interactive shell"
            env.ui.info "To exit interactive mode, use 'quit!'"

            while 1
              command = ui.ask("veewee>")
              case command.strip
              when 'quit!'
                env.ui.info 'Bye!'
                break
              else
                winrm_execute(self.ip_address,command,winrm_options.merge(options))
              end
            end
          else
            winrm_execute(self.ip_address,command,winrm_options.merge(options))
          end


        end

      end # Module
    end # Module
  end # Module
end # Module

