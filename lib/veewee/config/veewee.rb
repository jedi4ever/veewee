module Veewee
  class Config
    class Veewee

      attr_reader :env

      attr_accessor :loglevel


      # This initializes a new Veewee Environment
      # settings argument is a hash with the following options
      # - :environment_dir : base directory where all other directories are relative to, default to the current directory unless another path is specified
      # - :definition_dir  : the directory to look for definitions, defaults to $environment_dir/definitions
      # - :iso_dir         : directory to look for iso files, defaults to $environment_dir/iso
      # - :box_dir         : directory where box files are exported to, defaults to $environment_dir/boxes
      # - :veewee          : top directory of the veewee gem files
      # - :validation_dir  : directory that contains a list of validation tests, that can be run after building a box
      # - :template_dir    : directory that contains the template definitions that come with the veewee gem, defaults to the path relative to the gemfiles
      # - :tmp_dir         : directory that will be used for creating temporary files, needs to be rewritable, default to $environment_dir/tmp


      attr_accessor :template_path
      attr_accessor :definition_path

      def initialize(config)
        @env=config.env

        @loglevel=:info

        @template_path=[:internal,"templates"]
        @definition_path=["definitions"]

        env.logger.debug("done")

      end


    end #Class
  end #Module
end #Module
