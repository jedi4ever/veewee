require 'veewee/provider/core/provider'

module Veewee
  module Provider
    module Vmfusion
      class Provider < Veewee::Provider::Core::Provider

        #include ::Veewee::Provider::Vmfusion::ProviderCommand

        def check_requirements
          #unless gem_available?("fission")
          #raise ::Veewee::Error, "The Vmfusion Provider requires the gem 'fission' to be installed\n"+ "gem install fission"
          #end
        end


      end #End Class
    end # End Module
  end # End Module
end # End Module
