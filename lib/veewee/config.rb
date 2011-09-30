require 'veewee/config/veewee'
require 'veewee/config/collection'
require 'veewee/config/definition'
require 'veewee/config/builders'

require 'fileutils'

module Veewee
  class Config

    attr_accessor :veewee

    attr_reader :env

    attr_accessor :definitions
    attr_accessor :builders
    attr_accessor :definitions
    attr_accessor :templates
    attr_reader   :ostypes

    def initialize(options)
      @env=options[:env]
      env.logger.info("config") { "Initializing empty list of definitions in config" }

      @builders=::Veewee::Config::Builders.new(env)
      @definitions=Hash.new
      @templates=Hash.new

      # Read ostypes
      yamlfile=File.join(File.dirname(__FILE__),"config","ostypes.yml")
      env.logger.info "Reading ostype yamlfile #{yamlfile}"
      @ostypes=YAML.load_file(yamlfile)

      # Initialize with defaults
      @veewee=::Veewee::Config::Veewee.new(self)

    end

    def define()
      config=OpenStruct.new

      # Expose the veewee config
      config.veewee=@veewee

      # Assign definitions
      config.definition=::Veewee::Config::Definition.new(self)

      # Assign builders
      #config.builder=::Veewee::Config::Builder.new(self)

      # Process config file
      yield config

      @definitions=config.definition.components

    end

    # We put a long name to not clash with any function in the Veewee file itself
    def load_veewee_config()
      veewee_configurator=self
      begin
        filename=File.join(Dir.pwd,"Veeweefile")
        if File.exists?(filename)
          veeweefile=File.read(filename)
          veeweefile["Veewee::Config.run"]="veewee_configurator.define"
          #        http://www.dan-manges.com/blog/ruby-dsls-instance-eval-with-delegation
          instance_eval(veeweefile)
        else
          env.logger.info "No configfile found"
        end
      rescue LoadError => e
        env.ui.error "An error occurred"
        env.ui.error e.message
      rescue NoMethodError => e
        env.ui.error "Some method got an error in the configfile - Sorry"
        env.ui.error $!
        env.ui.error e.message
        exit -1
      rescue Error => e
        env.ui.error "Error processing configfile - Sorry"
        env.ui.error e.message
        exit -1
      end
      return self
    end



  end #End Class
end #End Module
