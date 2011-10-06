require 'veewee/provider/core/helper/ssh'
module Veewee
  module Provider
    module  Core
      module BoxCommand

        def shutdown(options={})
          self.ssh(sudo(definition.shutdown_cmd))
        end

      end # Module
    end # Module
  end # Module
end # Module
