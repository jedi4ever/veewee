require 'veewee/provider/core/helper/ssh'
module Veewee
  module Provider
    module  Core
      module BoxCommand

        def scp(localfile,remotefile,options={})
          raise Veewee::Error,"Box is not running" unless self.running?
          begin
            new_options=ssh_options.merge(options)
            self.when_ssh_login_works(self.ip_address,new_options) do
              begin
                env.logger.info "About to transfer #{localfile} to #{remotefile} to the box #{name} - #{self.ip_address} - #{new_options}"
                self.ssh_transfer_file(self.ip_address,localfile,remotefile,new_options)
              rescue RuntimeError => ex
                env.ui.error "Error transfering file #{localfile} failed, possible not enough permissions to write? #{ex}"
                raise Veewee::SshError,ex
              end
            end
          rescue Net::SSH::AuthenticationFailed => ex
            env.ui.error "Authentication failure"
            raise Veewee::SshError,ex
          end

        end
      end # Module
    end # Module
  end # Module
end # Module
