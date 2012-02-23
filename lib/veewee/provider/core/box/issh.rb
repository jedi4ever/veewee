require 'veewee/provider/core/helper/ssh'
module Veewee
  module Provider
    module  Core
      module BoxCommand

        def issh(command=nil,options={})
          self.ssh(command,options.merge({:interactive => true}))
        end

      end # Module
    end # Module
  end # Module
end # Module

