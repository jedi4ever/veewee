require 'veewee/provider/core/box'
require 'veewee/provider/core/helper/tcp'

require 'veewee/provider/parallels/box/helper/status'
require 'veewee/provider/parallels/box/helper/ip'
require 'veewee/provider/parallels/box/helper/console_type'
require 'veewee/provider/parallels/box/helper/buildinfo'

require 'veewee/provider/parallels/box/build'
require 'veewee/provider/parallels/box/export'
require 'veewee/provider/parallels/box/up'
require 'veewee/provider/parallels/box/create'
require 'veewee/provider/parallels/box/poweroff'
require 'veewee/provider/parallels/box/halt'
require 'veewee/provider/parallels/box/destroy'
require 'veewee/provider/parallels/box/ssh'


module Veewee
  module Provider
    module Parallels
      class Box < Veewee::Provider::Core::Box

        include ::Veewee::Provider::Parallels::BoxCommand
        include ::Veewee::Provider::Core::BoxCommand


        def initialize(name,env)
          super(name,env)
        end

      end # End Class
    end # End Module
  end # End Module
end # End Module
