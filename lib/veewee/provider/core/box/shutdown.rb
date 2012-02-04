require 'veewee/provider/core/helper/ssh'
module Veewee
  module Provider
    module  Core
      module BoxCommand

        def shutdown(options={})
          if self.running?
            if options["force"]==true
              self.halt
            else
              self.ssh("echo '#{definition.shutdown_cmd}' > /tmp/shutdown.sh")
              self.ssh(sudo("/tmp/shutdown.sh"))
            end
          else
            raise Veewee::Error,"Box is not running"
          end
        end

      end # Module
    end # Module
  end # Module
end # Module
