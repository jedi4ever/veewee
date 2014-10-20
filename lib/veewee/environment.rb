require 'veewee/config'
require 'veewee/definitions'
require 'veewee/templates'
require 'veewee/providers'

require 'logger'

module Veewee

  # Represents a single Veewee environment. A "Veewee environment" is
  # defined as basically a folder with a "Veeweefile". This class allows
  # access to the VMs, CLI, etc. all in the scope of this environment
  class Environment

    # The `cwd` that this environment represents
    attr_accessor :cwd

    # The valid name for a Veeweefile for this environment
    attr_accessor :veewee_filename

    # This initializes a new Veewee Environment
    # settings argument is a hash with the following options
    # - :definition_dir   : where definitions are located
    # - :template_path    : paths that contains the template definitions that come with the veewee gem, defaults to the path relative to the gemfiles
    # - :iso_dir         : directory to look for iso files, defaults to $environment_dir/iso
    # - :validation_dir  : directory that contains a list of validation tests, that can be run after building a box
    # - :tmp_dir         : directory that will be used for creating temporary files, needs to be rewritable, default to $environment_dir/tmp
    attr_accessor :template_path
    attr_writer   :definition_dir
    attr_writer   :iso_dir
    attr_accessor :validation_dir
    attr_writer   :tmp_dir

    # The {UI} Object to communicate with the outside world
    attr_writer :ui

    # The configuration as loaded
    attr_accessor :config

    # Hash element of all definitions available
    attr_accessor :definitions

    # Hash element of all templates available
    attr_accessor :templates

    # Hash element of all providers available
    attr_accessor :providers

    # Hash element of all OS types
    attr_reader :ostypes

    # Path to the config file
    attr_reader :config_filepath

    attr_accessor :current_provider

    def initialize(options = {})
      # symbolify commandline options
      options = options.inject({}) {|result,(key,value)| result.update({key.to_sym => value})}

      # If a cwd was provided as option it overrules the default
      # cwd is again merged later with all options but it has to merged here
      # because several defaults are generated from it
      cwd = options[:cwd] || Veewee::Environment.workdir

      defaults = {
        :cwd => cwd,
        :veewee_filename => "Veeweefile",
        :template_path => ["templates"],
        :validation_dir => File.join(File.expand_path(File.join(File.dirname(__FILE__), "..", "..")), "validation"),
      }

      options = defaults.merge(options)

      @config_filepath = File.join(options[:cwd], options[:veewee_filename])

      veeweefile_config = defaults.keys.inject({}) do |memo, obj|
        if config.env.methods.include?(obj) && !config.env.send(obj).nil?
          memo.merge({ obj => config.env.send(obj) })
        else
          memo
        end
      end
      options = options.merge(veeweefile_config)

      logger.info("environment") { "Environment initialized (#{self})" }

      # Injecting all variables of the options and assign the variables
      options.each do |key, value|
        instance_variable_set("@#{key}".to_sym, options[key])
        logger.info("environment") { " - #{key} : #{options[key]}" }
      end

      # Definitions
      @definitions = Veewee::Definitions.new(self)
      @templates = Veewee::Templates.new(self)
      @providers = Veewee::Providers.new(self, options)

      # Read ostypes
      yamlfile = File.join(File.dirname(__FILE__), "config", "ostypes.yml")
      logger.info "Reading ostype yamlfile #{yamlfile}"
      @ostypes = YAML.load_file(yamlfile)

      return self
    end

    def definition_dir
      @definition_dir ||= File.join(cwd, "definitions")
    end
    def iso_dir
      @iso_dir ||= File.join(cwd, "iso")
    end
    def tmp_dir
      tmp_dir ||= File.join(cwd, "tmp")
    end

    def self.workdir
      ENV['VEEWEE_DIR'] || Dir.pwd
    end

    #---------------------------------------------------------------
    # Config Methods
    #---------------------------------------------------------------

    # The configuration object represented by this environment. This
    # will trigger the environment to load if it hasn't loaded yet (see
    # {#load!}).
    #
    # @return [Config::Top]
    def config
      load! if !loaded?
      @config
    end

    # Returns the {UI} for the environment, which is responsible
    # for talking with the outside world.
    #
    # @return [UI]
    def ui
      @ui ||= UI.new(self)
    end

    #---------------------------------------------------------------
    # Load Methods
    #---------------------------------------------------------------

    # Returns a boolean representing if the environment has been
    # loaded or not.
    #
    # @return [Bool]
    def loaded?
      !!@loaded
    end

    # Loads this entire environment, setting up the instance variables
    # such as `vm`, `config`, etc. on this environment. The order this
    # method calls its other methods is very particular.
    def load!
      if !loaded?
        @loaded = true

        logger.info("environment") { "Loading configuration..." }
        load_config!

        self
      end
    end

    def load_config!
      @config = Config.new({ :env => self }).load_veewee_config()
      return self
    end

    # Reloads the configuration of this environment.
    def reload_config!
      @config = nil
      load_config!
      self
    end

    # Makes a call to the CLI with the given arguments as if they
    # came from the real command line (sometimes they do!). An example:
    #
    #     env.cli("package", "--veeweefile", "Veeweefie")
    #
    def cli(*args)
      CLI.start(args.flatten, :env => self)
    end

    def resource
      "veewee"
    end

    # Accesses the logger for Veewee. This logger is a _detailed_
    # logger which should be used to log internals only. For outward
    # facing information, use {#ui}.
    #
    # @return [Logger]
    def logger
      return @logger if @logger

      output = nil
      loglevel = Logger::ERROR

      # Figure out where the output should go to.
      if ENV["VEEWEE_LOG"]
        output = STDOUT
        loglevel = Logger.const_get(ENV["VEEWEE_LOG"].upcase)
      end

        # Create the logger and custom formatter
      @logger = ::Logger.new(output)
      @logger.level = loglevel
      @logger.formatter = Proc.new do |severity, datetime, progname, msg|
        "#{datetime} - #{progname} - [#{resource}] #{msg}\n"
      end
      @logger
    end

    # Get box from current provider
    def get_box(name)
      if current_provider.nil?
        raise "Provider is unset in the environment."
      else
        providers[current_provider].get_box(name)
      end
    end
  end #Class
end #Module
