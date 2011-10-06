require 'veewee/provider/core/provider'

module Veewee
  module Provider
    module Virtualbox
      class Provider < Veewee::Provider::Core::Provider

#        include ::Veewee::Provider::Virtualbox::ProviderCommand

        def check_requirements
          unless gem_available?("virtualbox")
            raise Veewee::Error,"The Virtualbox Provider requires the gem 'virtualbox' to be installed"
          end
        end


        def build_info
          info=super
          info << { :filename => ".vbox_version",
                    :content => "#{VirtualBox::Global.global.lib.virtualbox.version.split('_')[0]}" }
        end

      end #End Class
    end # End Module
  end # End Module
end # End Module
