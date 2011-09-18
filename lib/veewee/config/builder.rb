require 'veewee/config/component'
require 'ostruct'

module Veewee
  class Config
    class Builder

      attr_accessor :components
      attr_reader :env

      def initialize(config)
        @env=config.env
        @components=Hash.new
      end

      def define(name)
        # We do this for vagrant syntax
        # Depending on type, we create a variable of that type
        builder_stub=OpenStruct.new
        builder_stub.builder=OpenStruct.new

        env.logger.debug("config builder"){ "Start stubbing builder"}

        # Now we can 'execute' the config file using our stub component
        # For guessing the builder type
        yield builder_stub

        env.logger.debug("config builder"){ "End stubbing builder"}

        # After processing we extract the builder type and options again
        builder_type=builder_stub.builder.type
        builder_options=builder_stub.builder.options

        begin
          # Now that we know the actual builder, we can check if the builder has this type of component
          require_path='veewee/builder/'+builder_type.to_s.downcase+"/builder"
          require require_path

          # Now we can create the real builder
          real_builder=Object.const_get("Veewee").const_get("Builder").const_get(builder_type.to_s.capitalize).const_get("Builder").new(name,builder_options,env)
          builder_stub.builder=real_builder
          yield builder_stub

          components[name.to_s]=builder_stub.builder
        rescue Error => e
          env.ui.error "Error loading builder with #{name},#{$!}"
        end
      end

    end
  end
end #Module Veewee
