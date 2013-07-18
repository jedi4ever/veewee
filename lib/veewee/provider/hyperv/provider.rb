require 'veewee/provider/core/provider'
require 'veewee/provider/hyperv/box'

module Veewee
  module Provider
    module HyperV
      class Provider < Veewee::Provider::Core::Provider

        def check_requirements
          if !OS.windows?
            raise Veewee::Error,"HyperV provisioning only works on a Windows host"
          end

          command = Box.determine_pshyperv
          unless self.shell_exec(command).status == 0
            raise Veewee::Error,"Could not find PowerShell Management Library for Hyper-V, http://pshyperv.codeplex.com/"
          end
        end

      end #End Class
    end # End Module
  end # End Module
end # End Module
