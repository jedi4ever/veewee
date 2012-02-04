require 'veewee/provider/core/helper/ssh'
module Veewee
  module Provider
    module  Core
      module BoxCommand


        def ssh_command_string
         "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p #{ssh_options[:port]} -l #{definition.ssh_user} #{self.ip_address}"
        end

        def ssh(command,options={})
          raise Veewee::Error,"Box is not running" unless self.running?
          begin
            new_options=ssh_options.merge(options)
            self.when_ssh_login_works(self.ip_address,new_options) do
              begin
                env.logger.info "About to execute remote command #{command} on box #{name} - #{self.ip_address} - #{new_options}"
                result=self.ssh_execute(ip_address,command,new_options)
                return result
              rescue RuntimeError => ex
                env.ui.error "Error executing command #{command} : #{ex}"
                raise Veewee::SshError, ex
              end
            end
          rescue Net::SSH::AuthenticationFailed => ex
            env.ui.error "Authentication failure"
            raise Veewee::SshError, ex
          end

        end
      end # Module
    end # Module
  end # Module
end # Module
