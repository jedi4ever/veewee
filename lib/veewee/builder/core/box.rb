
module Veewee
  module Builder
    module Core
      class  Box
        attr_accessor :definition
        attr_accessor :env
        attr_accessor :name        
        
        def initialize(env,name)
          @env=env
          @name=name
        end

        def raw
          if @raw.nil?
            # Try to fetch raw
            @raw=nil
          else
            return @raw
          end
        end
        
        def exists?
          !raw.nil?
        end
        
        def create(definition)
        end
        
        def destroy
        end
        
        def start
        end
        
        def stop
        end
        
        def poweroff
        end
        
        def set_definition(definition_name)
          @definition=@environment.get_definition(definition_name)
        end        



      end #End Class
    end # End Module
  end # End Module
end # End Module
