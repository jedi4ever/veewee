require 'veewee/provider/core/helper/winrm'
module Veewee
  module Provider
    module  Core
      module BoxCommand

        def wincp(localfile,remotefile,options={})
          raise Veewee::Error,"Box is not running" unless self.running?
          begin
            self.when_winrm_login_works(self.ip_address,winrm_options.merge(options)) do
              env.ui.info "Going to try and copy #{localfile} to #{remotefile}"
              env.ui.error "However File copy via WINRM not implemented yet, look at core/helper/scp"
              env.ui.error "Maybe we should start up a web server and execute a retrieve?"
            end
          end
        end
      end # Module
    end # Module
  end # Module
end # Module
