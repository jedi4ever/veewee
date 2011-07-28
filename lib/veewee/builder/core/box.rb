require 'veewee/builder/core/helper/iso'

module Veewee
  module Builder
    module Core
      class  Box
        attr_accessor :definition
        attr_accessor :environment
        attr_accessor :box_name
        attr_accessor :options


        def initialize(environment,box_name,definition_name,box_options)
          @environment=environment
          @options=box_options
          @box_name=box_name
          @definition=@environment.get_definition(definition_name)
        end

        def set_definition(definition_name)
          @definition=@environment.get_definition(definition_name)
        end
        
      end #End Class
    end # End Module
  end # End Module
end # End Module