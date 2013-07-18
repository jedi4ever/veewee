require 'veewee/provider/core/box'

require 'veewee/provider/hyperv/box/build'
require 'veewee/provider/hyperv/box/create'
#require 'veewee/provider/virtualbox/box/halt'
#require 'veewee/provider/virtualbox/box/poweroff'
#require 'veewee/provider/virtualbox/box/destroy'
#require 'veewee/provider/virtualbox/box/screenshot'
#require 'veewee/provider/virtualbox/box/ssh'
#require 'veewee/provider/virtualbox/box/validate_vagrant'
#require 'veewee/provider/virtualbox/box/export_vagrant'
#require 'veewee/provider/virtualbox/box/helper/create'
#require 'veewee/provider/virtualbox/box/helper/ip'
#require 'veewee/provider/virtualbox/box/helper/forwarding'
#require 'veewee/provider/virtualbox/box/helper/natinterface'
#require 'veewee/provider/virtualbox/box/helper/ssh_options'
#require 'veewee/provider/virtualbox/box/helper/winrm_options'
#require 'veewee/provider/virtualbox/box/helper/guest_additions'
#require 'veewee/provider/virtualbox/box/helper/status'
#require 'veewee/provider/virtualbox/box/helper/version'
#require 'veewee/provider/virtualbox/box/helper/buildinfo'
#require 'veewee/provider/virtualbox/box/helper/console_type'
#require 'veewee/provider/virtualbox/box/up'

require 'whichr'

module Veewee
  module Provider
    module HyperV
      class Box < Veewee::Provider::Core::Box

        include ::Veewee::Provider::HyperV::BoxCommand

        def initialize(name,env)
          super(name, env)
        end

        def self.environment
          @command = "powershell -Command \"Get-Module HyperV\""
        end


      end # End Class
    end # End Module
  end # End Module
end # End Module
