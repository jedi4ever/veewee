require 'veewee/provider/core/helper/winrm'
module Veewee
  module Provider
    module  Core
      module BoxCommand


        def winrm(command=nil,options={})

          raise Veewee::Error,"Box is not running" unless self.running?

          if (options[:interactive]==true)
            env.ui.info "WINRM NOT INTERACTIVE YET"
          end
          winrm_options={:user => definition.winrm_user,:password => definition.winrm_password, :port => definition.winrm_host_port}
          winrm_execute(self.ip_address,command,winrm_options.merge(options))

        end

        private
        def winrm_options(options)

          command_options = [
            #"-q", #Suppress warning messages
            #            "-T", #Pseudo-terminal will not be allocated because stdin is not a terminal.
            "-p #{winrm_options[:port]}",
            "-o UserKnownHostsFile=/dev/null",
            "-t -o StrictHostKeyChecking=no",
            "-o IdentitiesOnly=yes",
            "-o VerifyHostKeyDNS=no"
          ]
          if !(definition.winrm_key.nil? ||  definition.winrm_key.length!="")
            command_options << "-i #{definition.winrm_key}"
          end
          commandline_options="#{command_options.join(" ")} ".strip

          user_option=definition.winrm_user.nil? ? "" : "-l #{definition.winrm_user}"

          return "#{commandline_options} #{user_option}"
        end
      end # Module
    end # Module
  end # Module
end # Module

