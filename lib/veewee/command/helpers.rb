module Veewee
  module Command
    module Helpers
      # Initializes the environment by pulling the environment out of
      # the configuration hash and sets up the UI if necessary.
      def initialize_environment(args, options, config)
        raise Errors::CLIMissingEnvironment if !config[:env]
        @env = config[:env]
      end

     end
  end
end