require 'veewee/provider/core/helper/ssh'
module Veewee
  module Provider
    module  Core
      module BoxCommand

        def iwinrm(command=nil,options={})
          self.winrm(command,options.merge({:interactive => true}))
        end

      end # Module
    end # Module
  end # Module
end # Module

