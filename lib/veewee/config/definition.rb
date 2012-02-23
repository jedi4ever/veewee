require 'veewee/config/component'
require 'veewee/definition'

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
      
      # Currently not used, this is in case we will specify the a definition in the Veeweefile
      # This is for future needs
      def define(name)
        # Depending on type, we create a variable of that type
        definition_stub=OpenStruct.new

        begin        
        # Get a real definition object
        real_definition=::Veewee::Definition.new(name,env)
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
