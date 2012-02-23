require 'veewee/provider/core/provider'

module Veewee
  module Provider
    module Vmfusion
      class Provider < Veewee::Provider::Core::Provider

        #include ::Veewee::Provider::Vmfusion::ProviderCommand

        def check_requirements
          unless File.exists?("/Library/Application Support/VMware Fusion/vmrun")
            raise Veewee::Error,"The file /Library/Application Support/VMware Fusion/vmrun does not exists. Probably you don't have Vmware fusion installed"
          end
        end


      end #End Class
    end # End Module
  end # End Module
end # End Module
