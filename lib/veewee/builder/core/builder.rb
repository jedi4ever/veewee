require 'veewee/builder/virtualbox/box'

module Veewee  
  module Builder
    module Core
      class Builder

        attr_accessor :environment
        attr_accessor :options
        attr_accessor :type

        # This is a generic class that will be implemeted by each boxbuilder
        # It passes the options builder_options and links the environment to its
        def initialize(builder_options,environment)
          @environment=environment
          @options=builder_options
          type=self.class.to_s
          # Strip out the module path Veewee::Builder::Virtualbox::Builder
          type['Veewee::Builder::']=''
          type['::Builder']=''
          @type=type
        end

        # This function asks a builder to initialize a box,with a name and definition
        def get_box(box_name,definition_name=nil,box_options={})
          if definition_name.nil?
            definition_name=box_name
          end
          box_class=Object.const_get("Veewee").const_get("Builder").const_get(@type).const_get('Box')
          box=box_class.new(@environment,box_name,definition_name,box_options)
          return box
        end

      end #End Class

    end #End Module
  end #End Module
end #End Module
