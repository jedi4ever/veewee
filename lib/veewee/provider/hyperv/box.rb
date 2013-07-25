require 'veewee/provider/core/box'

require 'veewee/provider/hyperv/box/util/powershell'
#require 'veewee/provider/hyperv/box/util/vm'
require 'veewee/provider/hyperv/box/build'
require 'veewee/provider/hyperv/box/create'
require 'veewee/provider/hyperv/box/halt'
require 'veewee/provider/hyperv/box/poweroff'
require 'veewee/provider/hyperv/box/destroy'
#require 'veewee/provider/hyperv/box/screenshot'
#require 'veewee/provider/hyperv/box/ssh'
#require 'veewee/provider/hyperv/box/validate_vagrant'
#require 'veewee/provider/hyperv/box/export_vagrant'
require 'veewee/provider/hyperv/box/helper/create'
#require 'veewee/provider/hyperv/box/helper/ip'
#require 'veewee/provider/hyperv/box/helper/forwarding'
#require 'veewee/provider/hyperv/box/helper/natinterface'
#require 'veewee/provider/hyperv/box/helper/ssh_options'
#require 'veewee/provider/hyperv/box/helper/winrm_options'
#require 'veewee/provider/hyperv/box/helper/guest_additions'
require 'veewee/provider/hyperv/box/helper/network'
require 'veewee/provider/hyperv/box/helper/status'
require 'veewee/provider/hyperv/box/helper/storage'
#require 'veewee/provider/hyperv/box/helper/version'
#require 'veewee/provider/hyperv/box/helper/buildinfo'
#require 'veewee/provider/hyperv/box/helper/console_type'
require 'veewee/provider/hyperv/box/up'

require 'whichr'

module Veewee
  module Provider
    module Hyperv
      class Box < Veewee::Provider::Core::Box

        include ::Veewee::Provider::Hyperv::BoxCommand

        def initialize(name,env)
          super(name,env)
        end

      end # End Class
    end # End Module
  end # End Module
end # End Module
