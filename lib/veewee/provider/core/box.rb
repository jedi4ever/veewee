require 'veewee/provider/core/helper/tcp'
require 'veewee/provider/core/helper/ssh'
require 'veewee/provider/core/helper/web'
require 'veewee/provider/core/helper/shell'
require 'veewee/provider/core/helper/iso'

require 'veewee/provider/core/box/build'
require 'veewee/provider/core/box/scp'
require 'veewee/provider/core/box/ssh'
require 'veewee/provider/core/box/shutdown'
require 'veewee/provider/core/box/sudo'
require 'veewee/provider/core/box/issh'

module Veewee
  module Provider
    module Core
      class  Box
        attr_accessor :definition
        attr_accessor :env
        attr_accessor :name

        include ::Veewee::Provider::Core::Helper::Tcp
        include ::Veewee::Provider::Core::Helper::Web
        include ::Veewee::Provider::Core::Helper::Shell
        include ::Veewee::Provider::Core::Helper::Ssh
        include ::Veewee::Provider::Core::Helper::Iso

        include ::Veewee::Provider::Core::BoxCommand

        def initialize(name,env)
          @env=env
          @name=name
          self.set_definition(name)
        end

        def set_definition(definition_name)
          @definition=env.definitions[definition_name]
          return self
        end

        def reload
          @raw=nil
        end


      end #End Class
    end # End Module
  end # End Module
end # End Module
