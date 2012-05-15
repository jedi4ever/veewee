require 'veewee/provider/core/helper/ssh'
module Veewee
  module Provider
    module  Core
      module BoxCommand

        def ssh_command_string
         "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p #{ssh_options[:port]} -l #{definition.ssh_user} #{self.ip_address}"
        end

        def exec(command,options={})
          raise Veewee::Error,"Box is not running" unless self.running?
          begin
            new_options=ssh_options.merge(options)
            self.when_ssh_login_works(self.ip_address,new_options) do
              begin
                env.logger.info "About to execute remote command #{command} on box #{name} - #{self.ip_address} - #{new_options}"
                result=self.ssh_execute(self.ip_address,command,new_options)
                return result
              rescue RuntimeError => ex
                error= "Error executing command #{command} : #{ex}"
                error+="\n#{ex.backtrace.join("\n")}" unless ex.backtrace.empty?
                raise Veewee::SshError, error
              end
            end
          rescue Net::SSH::AuthenticationFailed => ex
            raise Veewee::SshError, "Authentication failure\n"+ex
          end

        end
      end # Module
    end # Module
  end # Module
end # Module
