require 'veewee/provider/core/helper/ssh'
module Veewee
  module Provider
    module  Core
      module BoxCommand

        def ssh_command_string
         "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p #{ssh_options[:port]} -l #{definition.ssh_user} #{self.ip_address}"
        end

        def winrm_command_string
          "knife winrm -m #{self.ip_address} -P #{winrm_options[:port]} -x #{definition.winrm_user}" +
            " -P #{definition.winrm_password} COMMAND"
        end

        def exec(command,options={})
          raise Veewee::Error,"Box is not running" unless self.running?
          if definition.winrm_user && definition.winrm_password
            begin
              new_options=winrm_options.merge(options)
              self.when_winrm_login_works(self.ip_address,winrm_options.merge(options)) do
                result = self.winrm_execute(self.ip_address,command,new_options)
                return result
              end
            rescue RuntimeError => ex
              env.ui.error "Error executing command #{command} : #{ex}"
              raise Veewee::WinrmError, ex
            end
          else # definition.ssh_user && definition.ssh_password
            begin
              new_options=ssh_options.merge(options)
              self.when_ssh_login_works(self.ip_address,new_options) do
                begin
                  env.logger.info "About to execute remote command #{command} on box #{name} - #{self.ip_address} - #{new_options}"
                  result=self.ssh_execute(self.ip_address,command,new_options)
                  return result
                rescue RuntimeError => ex
                  env.ui.error "Error executing command #{command} : #{ex}"
                  raise Veewee::SshError, ex
                end
              end
            rescue Net::SSH::AuthenticationFailed => ex # may want to catch winrm auth fails as well
              env.ui.error "Authentication failure"
              raise Veewee::SshError, "Authentication failure\n"+ex.inspect
            end
          end


        end
      end # Module
    end # Module
  end # Module
end # Module
