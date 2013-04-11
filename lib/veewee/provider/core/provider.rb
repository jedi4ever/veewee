require 'veewee/provider/core/helper/shell'
module Veewee
  module Provider
    module Core
      class Provider

        attr_accessor :env
        attr_accessor :options

        attr_accessor :type
        attr_accessor :name

        include ::Veewee::Provider::Core::Helper::Shell

        def ui
          return @_ui if defined?(@_ui)
          @_ui = @env.ui.dup
          @_ui.resource = @name
          @_ui
        end

        def initialize(name,options,env)

          @env=env
          @name=name
          @options=options
          @type=self.class.to_s.split("::")[-2]
          check_requirements
        end

        def get_box(name)
          begin
            require_path='veewee/provider/'+type.to_s.downcase+"/box.rb"
            require require_path

            # Get a real box object from the Provider
            box=Object.const_get("Veewee").const_get("Provider").const_get(type.to_s.capitalize).const_get("Box").new(name,env)

            # Attach the provider to the box
            box.provider = self

            return box
          rescue Error => ex
            ui.error "Could not instantiate the box #{name} with provider #{type} ,#{ex}"
            raise
          end
        end

        def self.available?
          begin
            self.check_requirements
            return true
          rescue Error
            return false
          end
        end

        def gem_available?(gemname)
          env.logger.info "Checking for gem #{gemname}"
          available=false
          begin
            available=true unless Gem::Specification::find_by_name("#{gemname}").nil?
          rescue Gem::LoadError
            env.logger.info "Error loading gem #{gemname}"
            available=false
          rescue
            env.logger.info "Falling back to old syntax for #{gemname}"
            available=Gem.available?("#{gemname}")
            env.logger.info "Old syntax #{gemname}.available? #{available}"
          end
          return available
        end

        def gems_available?(names)
          names.each do |gemname|
            return false if !gem_available?(gemname)
          end
          return true
        end

      end #End Class

    end #End Module
  end #End Module
end #End Module
