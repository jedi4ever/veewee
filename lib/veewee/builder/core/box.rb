require 'veewee/util/tcp'
require 'veewee/util/web'
require 'veewee/util/ssh'
require 'veewee/util/shell'

module Veewee
  module Builder
    module Core
      class  Box
        attr_accessor :definition
        attr_accessor :env
        attr_accessor :name

        include ::Veewee::Util::Tcp
        include ::Veewee::Util::Web
        include ::Veewee::Util::Ssh
        include ::Veewee::Util::Shell

        def initialize(name,env)
          @env=env
          @name=name
        end

        def reload
          @raw=nil
        end


      end #End Class
    end # End Module
  end # End Module
end # End Module
