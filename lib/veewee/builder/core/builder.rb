require 'veewee/util/shell'
require 'veewee/util/tcp'
require 'veewee/util/web'
require 'veewee/util/ssh'

require 'veewee/builder/core/builder/build.rb'
require 'veewee/builder/core/builder/iso.rb'

module Veewee
  module Builder
    module Core
      class Builder

        attr_accessor :env
        attr_accessor :options

        attr_accessor :type
        attr_accessor :name

        include ::Veewee::Builder::Core::BuilderCommand

        def initialize(name,options,env)

          @name=name
          @options=options
          @env=env

          @type=self.class.to_s.split("::")[-2]

        end

        def get_definition(name)
          env.logger.info("fetching definition #{name}")
          definition=env.get_definition(name)
          return definition
        end

        def get_box(name)
          begin
            require_path='veewee/builder/'+type.to_s.downcase+"/box.rb"
            require require_path

            # Get a real box object from the builder
            box=Object.const_get("Veewee").const_get("Builder").const_get(type.to_s.capitalize).const_get("Box").new(name,env)
          rescue Error => ex
            env.ui.error "Could not instante the box #{name} with provider #{type} ,#{ex}"
          end
        end

        def check_gem_availability(gems)
          gems.each do |gemname|
            availability_gem=false
            begin
              availability_gem=true unless Gem::Specification::find_by_name("#{gemname}").nil?
            rescue Gem::LoadError
              availability_gem=false
            rescue
              availability_gem=Gem.available?("#{gemname}")
            end
            unless availability_gem
              env.ui.error "The #{gemname} gem is not installed and is required by the #{@name.to_sym} provider"
            end
          end
        end
        

      end #End Class

    end #End Module
  end #End Module
end #End Module
