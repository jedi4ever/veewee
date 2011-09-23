require 'veewee/config/component'
require 'ostruct'

module Veewee
  class Config

    class Builders
      def initialize(env)
        @env=env
        @builders=Hash.new
      end

      def [](name)
             return @builders[name] if @builders.has_key?(name)

             begin
               # Now that we know the actual builder, we can check if the builder has this type of component
               require_path='veewee/builder/'+name.to_s.downcase+"/builder"
               require require_path

               # Now we can create the real builder
               real_builder=Object.const_get("Veewee").const_get("Builder").const_get(name.to_s.capitalize).const_get("Builder").new(name,{},@env)
             rescue ::Veewee::Error => e
                raise
             rescue Error => e
               env.ui.error "Error loading builder with #{name},#{$!}"
             end
      end

      def length
        @builders.length
      end

    end
  end
end #Module Veewee
