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
              self.exec("echo '#{definition.shutdown_cmd}' > /tmp/shutdown.sh")
              self.exec("chmod +x /tmp/shutdown.sh")
              self.exec(sudo("/tmp/shutdown.sh"))
            end
          else
            raise Veewee::Error,"Box is not running"
          end
        end

      end # Module
    end # Module
  end # Module
end # Module
