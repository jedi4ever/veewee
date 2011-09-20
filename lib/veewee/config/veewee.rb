module Veewee
  class Config
    class Veewee

      attr_reader :env

      def initialize(config)
        @env=config.env
        env.logger.info("Initializing veewee config object")
      end

      def method_missing(m, *args, &block)
        @env.send(m, *args)
      end

    end #Class
  end #Module
end #Module



