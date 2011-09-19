require 'veewee/config/veewee'
require 'veewee/config/collection'
require 'veewee/config/definition'
require 'veewee/config/builder'

require 'fileutils'

module Veewee
  class Config

    attr_accessor :veewee

    attr_reader :env

    attr_accessor :definitions
    attr_accessor :builders
    attr_accessor :definitions
    attr_accessor :templates

    def initialize(options)
      @env=options[:env]
      env.logger.info("config") { "Initializing empty list of definitions in config" }

      @builders=Hash.new
      @definitions=Hash.new
      @templates=Hash.new

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
      config.builder=::Veewee::Config::Builder.new(self)

      # Process config file
      yield config

      @definitions=config.definition.components
      @builders=config.builder.components

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


    # Loading the builders
    def load_builders()
      %w{vmfusion kvm virtualbox}.each do |name|
        config=OpenStruct.new
        config.env=env
        config.builder=::Veewee::Config::Builder.new(config)
        config.builder.define(name) do |config|
          config.builder.name="#{name}"
          config.builder.type="#{name}"
        end
        env.config.builders.merge!(config.builder.components)

      end

    end


    # Loading the definitions directories
    def load_definitions()
      # Read definitions from definitionspath
      env.ui.info "Loading definitions from definition path"
      paths=env.config.veewee.definition_path

      expanded_paths=paths.collect { |t| t==:internal ?  File.join(File.dirname(__FILE__),"..","..","definitions") : t }

      valid_paths=expanded_paths.collect { |path|
        if File.exists?(path) && File.directory?(path)
          env.logger.info "Definition path #{path} exists"
          return File.expand_path(path)
        else
          env.logger.info "Definition path #{path} does not exist, skipping"
          return nil
        end
      }

      # Create a dummy config
      config=OpenStruct.new
      config.env=env
      config.definition=::Veewee::Config::Definition.new(config)

      veewee_configurator=config

      # For all paths that exist
      valid_paths.compact.each do |path|

        # Read subdirectories
        definition_dirs=Dir[File.join(path,"**")].reject{|d| not File.directory?(d)}
        definition_dirs.each do |dir|
          definition_file=File.join(dir,"definition.rb")
          if File.exists?(definition_file)
            definition=File.read(definition_file)
            name=File.basename(dir)
            definition["Veewee::Session.declare("]="veewee_configurator.definition.declare(\"#{name}\","

            env.logger.info(definition)

            begin
              cwd=FileUtils.pwd
              FileUtils.cd(dir)
              config.instance_eval(definition)
              config.definition.components[name].path=File.dirname(definition_file)
              env.logger.info("Setting definition path for definition #{name} to #{File.dirname(definition_file)}")
              FileUtils.cd(cwd)
            rescue NameError => ex
              env.ui.error("NameError reading definition from file #{definition_file} #{ex}")
            rescue Exception => ex
              env.ui.error("Error reading definition from file #{definition_file}#{ex}")
            end
          else
            env.logger.info "#{definition_file} not found"
          end
        end

      end

      env.config.definitions.merge!(config.definition.components)
    end

  end #End Class
end #End Module
