require 'veewee/provider/core/box'

require 'veewee/provider/virtualbox/box/build'
require 'veewee/provider/virtualbox/box/create'
require 'veewee/provider/virtualbox/box/halt'
require 'veewee/provider/virtualbox/box/poweroff'
require 'veewee/provider/virtualbox/box/destroy'
require 'veewee/provider/virtualbox/box/screenshot'
require 'veewee/provider/virtualbox/box/ssh'
require 'veewee/provider/virtualbox/box/validate_vagrant'
require 'veewee/provider/virtualbox/box/export_vagrant'
require 'veewee/provider/virtualbox/box/helper/create'
require 'veewee/provider/virtualbox/box/helper/ip'
require 'veewee/provider/virtualbox/box/helper/forwarding'
require 'veewee/provider/virtualbox/box/helper/natinterface'
require 'veewee/provider/virtualbox/box/helper/ssh_options'
require 'veewee/provider/virtualbox/box/helper/guest_additions'
require 'veewee/provider/virtualbox/box/helper/status'
require 'veewee/provider/virtualbox/box/helper/version'
require 'veewee/provider/virtualbox/box/helper/buildinfo'
require 'veewee/provider/virtualbox/box/helper/console_type'
require 'veewee/provider/virtualbox/box/up'

module Veewee
  module Provider
    module Virtualbox
      class Box < Veewee::Provider::Core::Box

        include ::Veewee::Provider::Virtualbox::BoxCommand

        def initialize(name,env)

          #require 'virtualbox'
          @vboxcmd=determine_vboxcmd
          super(name,env)

        end

        def determine_vboxcmd
          return "VBoxManage"
        end


      end # End Class
    end # End Module
  end # End Module
end # End Module
