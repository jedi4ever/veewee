require 'veewee/provider/core/helper/ssh'
module Veewee
  module Provider
    module  Core
      module BoxCommand

        def halt(options={})
          if self.running?
            if options["force"]==true
              self.poweroff
            else
              if definition.winrm_user && definition.winrm_password # prefer winrm 
                self.exec("#{definition.shutdown_cmd}")
              else
                self.exec("echo '#{definition.shutdown_cmd}' > /tmp/shutdown.sh")
                self.exec("chmod +x /tmp/shutdown.sh")
                self.exec(sudo("/tmp/shutdown.sh"))
              end
            end
          else
            raise Veewee::Error,"Box is not running"
          end
        end

      end # Module
    end # Module
  end # Module
end # Module
