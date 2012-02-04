require 'veewee/config/component'
require 'ostruct'

module Veewee
  class Config
    class Collection

      attr_accessor :components
      attr_accessor :type
      attr_accessor :config

      attr_reader   :env

      def initialize(type,config)
        @type=type
        @components=Hash.new
        @providers=config.providers
        @config=config
        @env=config.env
      end

      def define(name)
        # We do this for vagrant syntax
        # Depending on type, we create a variable of that type
        # f.i. component_stub.vm or component_stub.lb
        component_stub=OpenStruct.new
        component_stub.send("#{@type}=",::Veewee::Config::Component.new(config))

        env.logger.info("config collection"){ "First pass of reading the config"}
        # Now we can 'execute' the config file using our stub component
        # For guessing the provider type
        yield component_stub

        env.logger.debug("config collection"){ "Stubs collection type #{@type} is loaded"}

        # After processing we extract the component again
        component=component_stub.send("#{@type}")
        provider=@providers[component.provider.to_s]

        env.logger.debug("config collection"){ "We get here"}

        abort "Provider #{component.provider.to_s} does not (yet) exist" if provider.nil?
        real_component=provider.get_component(@type.capitalize,env)
        begin

          # And repeat the same process with a real component
          env.logger.debug("config collection"){ "Component of #{@type}"}

          component_stub.send("#{@type}=",real_component)

          yield component_stub
          # After processing we extract the component again
          component=component_stub.send("#{@type}")
          # And we set the name
          component.name=name

          # We set the provider for this component
          component.provider=provider

          # And register this component with the provider
          # if it is a vm, we add to the hash vms
          # if it is an ip, we add it to the hash ips
          provider_collection=provider.instance_variable_get("@#{@type}s")
          provider_collection[name]=component

          # And we also add it to the global config element
          # So we can have all components of a similar type in one place
          config_collection=@config.instance_variable_get("@#{@type}s")
          config_collection[name]=component

          # Now we can ask the component to validate itself
          #component_stub.validate
          components[name.to_s]=component

        rescue Error => e
          env.ui.error "Error loading component with #{name} of type #{@type} for provider #{component.provider.type}"
        end
      end

    end
  end
end #Module Veewee
