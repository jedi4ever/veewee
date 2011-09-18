require 'veewee/config/component'
require 'ostruct'

module Veewee
  class Config
    class Definition

      attr_accessor :components
      attr_reader :env

      def initialize(config)
        @env=config.env
        @components=Hash.new
      end

      # This is the old syntax (it defines a box + definition using the same name)
      def declare(name,options)
     
        env.logger.debug("config definition"){ "Start declaring definition"}
      
        # So we first register the defintion
        self.define(name) do |definition|
          # we need to inject all keys as instance variables & attr_accessors
          options.keys.each do |key|
            definition.send("#{key.to_s}=",options[key])
          end
        end
        
        # And now register a box with the same name
        
        env.logger.debug("config definition"){ "End declaring definition"}
             
      end
      
      def define(name)
        # Depending on type, we create a variable of that type
        definition_stub=OpenStruct.new

        builder_type="vmfusion"
        
        begin
        # Load required builder
        require_path='veewee/builder/'+builder_type.to_s.downcase+"/definition.rb"
        require require_path
        
        # Get a real definition object from the builder
        real_definition=Object.const_get("Veewee").const_get("Builder").const_get(builder_type.to_s.capitalize).const_get("Definition").new(name,env)
        rescue Error => e
          env.ui.error "Error loading provider with #{name},#{$!}"
        end
        
        definition_stub.definition=real_definition

        env.logger.debug("config definition"){ "Start defining definition"}

        yield definition_stub

        env.logger.debug("config definition"){ "End defining definition #{definition_stub.definition.name}"}

        components[name.to_s]=definition_stub.definition
      end

    end
  end
end #Module Veewee
