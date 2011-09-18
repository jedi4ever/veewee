require 'veewee/builder/core/builder/build.rb'

module Veewee  
  module Builder
    module Core
      class Builder

        attr_accessor :env
        attr_accessor :options

        attr_accessor :type
        attr_accessor :name

        attr_accessor :boxes

        include ::Veewee::Builder::Core::BuilderCommand
        
        def initialize(name,options,env)
          
          @name=name
          @options=options
          @env=env

          @type=self.class.to_s.split("::")[-2]
          
          @boxes=Hash.new
          
        end

        def get_component(type,env)
          real_component=nil
          begin
            # Now that we know the actual provider, we can check if the provider has this type of component
            require_path='mccloud/provider/'+@type.to_s.downcase+"/"+type
            require require_path
            # Now we can create the real component

            env.logger.debug("provide #{@type} about to create component of type #{type}")

            real_component=Object.const_get("Veewee").const_get("Builder").const_get(@type.to_s.capitalize).const_get(type.to_s.capitalize).new(env)

          rescue Error => e
            puts "Error getting component - #{e}"
          end
          return real_component
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
              abort "The #{gemname} gem is not installed and is required by the #{@name.to_sym} provider"
              exit
            end
          end
        end
        

      end #End Class

    end #End Module
  end #End Module
end #End Module
