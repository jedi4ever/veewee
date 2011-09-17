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

      def declare(name,options)
        
        # Initialize options via hash

        definition_stub=OpenStruct.new
        env.logger.debug("config definition"){ "Start declaring definition"}

        builder_type="vmfusion"
        
        begin
        # Load required builder
        require_path='veewee/builder/'+builder_type.to_s.downcase+"/definition.rb"
        require require_path

        # Get a real definition object from the builder
        real_definition=Object.const_get("Veewee").const_get("Builder").const_get(builder_type.to_s.capitalize).const_get("Definition").new(name,env)
        
        definition_stub.definition=real_definition
        
        env.logger.debug("config definition"){ "End declaring definition #{definition_stub.definition.name}"}
        
        components[name.to_s]=definition_stub.definition
        
        # we need to inject all keys as instance variables & attr_accessors
        options.keys.each do |key|
          definition_stub.definition.send("#{key.to_s}=",options[key])
        end      
        
        rescue Error => e
          env.ui.error "Error loading provider with #{name},#{$!}"
        end
                
      end
      
      def define(name)
        # Depending on type, we create a variable of that type
        definition_stub=OpenStruct.new
        definition_stub.definition=::Veewee::Definition.new(name,env)

        env.logger.debug("config definition"){ "Start defining definition"}

        yield definition_stub

        env.logger.debug("config definition"){ "End defining definition #{definition_stub.definition.name}"}

        components[name.to_s]=definition_stub.definition
      end

    end
  end
end #Module Veewee
