module Veewee
  class Config
    class Component

      attr_accessor :provider
      
      attr_reader   :env

      def initialize(config)
        @env=config.env
      end

      def method_missing(m, *args, &block)  
#         puts "There's no method called #{m} here -- please try again."  
       end
             
    end
  end
end #Module Veewee
