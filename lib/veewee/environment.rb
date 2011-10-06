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

    attr_accessor :loglevel

    # This initializes a new Veewee Environment
    # settings argument is a hash with the following options
    # - :definition_dir   : where definitions are located
    # - :template_path    : paths that contains the template definitions that come with the veewee gem, defaults to the path relative to the gemfiles
    # - :iso_dir         : directory to look for iso files, defaults to $environment_dir/iso
    # - :validation_dir  : directory that contains a list of validation tests, that can be run after building a box
    # - :tmp_dir         : directory that will be used for creating temporary files, needs to be rewritable, default to $environment_dir/tmp
    attr_accessor :template_path
    attr_accessor :definition_dir
    attr_accessor :iso_dir
    attr_accessor :validation_dir
    attr_accessor :tmp_dir

    # The {UI} Object to communicate with the outside world
    attr_writer :ui

    # The configuration as loaded
    attr_accessor :config

    # Hash element of all definitions available
    attr_accessor :definitions

    # Hash element of all templates available
    attr_accessor :templates

    # Hash element of all templates available
    attr_accessor :providers

    # Hash elelement of all OStypes
    attr_reader :ostypes

    def initialize(options={})

      cwd= options.has_key?(:cwd) ? options[:cwd] : Dir.pwd

      defaults={
        :cwd => cwd,
        :veewee_filename => "Veeweefile",
        :loglevel => :info,
        :definition_dir => File.join(cwd,"definitions"),
        :template_path => [File.expand_path(File.join(File.dirname(__FILE__),"..","..",'templates')),"templates"],
        :iso_dir => File.join(cwd,"iso"),
        :validation_dir => File.join(File.expand_path(File.join(File.dirname(__FILE__),"..","..")),"validation"),
        :tmp_dir => File.join(cwd,"tmp")
      }

      options = defaults.merge(options)

      # We need to set this variable before the first call to the logger object
      if options.has_key?("debug")
        ENV['VEEWEE_LOG']="STDOUT"
      end

      logger.info("environment") { "Environment initialized (#{self})" }

      # Injecting all variables of the options and assign the variables
      options.each do |key, value|
        instance_variable_set("@#{key}".to_sym, options[key])
        logger.info("environment") { " - #{key} : #{options[key]}" }
      end

      # Definitions
      @definitions=Veewee::Definitions.new(self)
      @templates=Veewee::Templates.new(self)
      @providers=Veewee::Providers.new(self)

      # Read ostypes
      yamlfile=File.join(File.dirname(__FILE__),"config","ostypes.yml")
      logger.info "Reading ostype yamlfile #{yamlfile}"
      @ostypes=YAML.load_file(yamlfile)

      return self
    end

#    def list_ostypes
      #@ui.info "The following are possible os_types you can use in your definition.rb files"
#
      #config.ostypes.each { |key,value|
        #@ui.info "#{key}"
      #}
    #end

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
      @ui ||=  UI.new(self)
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
      @config=Config.new({:env => self}).load_veewee_config()

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

      # Figure out where the output should go to.
      output = nil
      if ENV["VEEWEE_LOG"] == "STDOUT"
        output = STDOUT
      elsif ENV["VEEWEE_LOG"] == "NULL"
        output = nil
      elsif ENV["VEEWEE_LOG"]
        output = ENV["VEEWEE_LOG"]
      else
        output = nil #log_path.join("#{Time.now.to_i}.log")
      end

      # Create the logger and custom formatter
      @logger = ::Logger.new(output)
      @logger.formatter = Proc.new do |severity, datetime, progname, msg|
        "#{datetime} - #{progname} - [#{resource}] #{msg}\n"
      end

      @logger
    end

  end #Class
end #Module
