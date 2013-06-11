require 'veewee/provider/core/provider'
require 'veewee/provider/virtualbox/box'

module Veewee
  module Provider
    module Virtualbox
      class Provider < Veewee::Provider::Core::Provider

#        include ::Veewee::Provider::Virtualbox::ProviderCommand

        def check_requirements
          command = Box.determine_vboxcmd
          unless self.shell_exec("#{command} -v").status == 0
            raise Veewee::Error,"Could not execute VBoxManage command. Please install Virtualbox or make sure VBoxManage is in the Path"
          end
        end

      end #End Class
    end # End Module
  end # End Module
end # End Module
