
module Veewee
  module Builder
    module Core
      class  Box
        attr_accessor :definition
        attr_accessor :env
        attr_accessor :name

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
