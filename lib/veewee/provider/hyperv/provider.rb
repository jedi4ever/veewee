require 'veewee/provider/core/provider'
require 'veewee/provider/hyperv/box'

module Veewee
  module Provider
    module Hyperv
      class Provider < Veewee::Provider::Core::Provider

        def check_requirements
          raise Veewee::Error,"HyperV provisioning only works on a Windows host" unless OS.windows?

          #TODO: Use local HyperV powershell tools see (doc/hyperv.md) for details
          #env.ui.info "Powershell -Command Get-Module HyperV"
          #unless self.shell_exec("Powershell -Command Get-Module HyperV").status == 0
          #  raise Veewee::Error,"Could not find PowerShell Management Library for Hyper-V, http://pshyperv.codeplex.com/"
          #end
        end

      end #End Class
    end # End Module
  end # End Module
end # End Module
