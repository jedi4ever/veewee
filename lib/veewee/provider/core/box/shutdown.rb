require 'veewee/provider/core/helper/ssh'
module Veewee
  module Provider
    module  Core
      module BoxCommand

        def shutdown(options={})
          if self.running?
            require 'pp'
            if options["force"]==true
              self.halt
            else
              self.ssh(sudo(definition.shutdown_cmd))
            end
          else
            raise Veewee::Error,"Box is not running"
          end
        end

      end # Module
    end # Module
  end # Module
end # Module
