module Veewee

    class Providers
      def initialize(env)
        @env=env
        @providers=Hash.new
      end

      def [](name)
             return @providers[name] if @providers.has_key?(name)

             begin
               require_path='veewee/provider/'+name.to_s.downcase+"/provider"
               require require_path

               provider=Object.const_get("Veewee").const_get("Provider").const_get(name.to_s.capitalize).const_get("Provider").new(name,{},@env)

               @providers[name]=provider
             rescue ::Veewee::Error => e
                raise
             rescue Error => e
               env.ui.error "Error loading provider with #{name},#{$!}"
             end
      end

      def length
        @providers.length
      end

  end
end #Module Veewee
