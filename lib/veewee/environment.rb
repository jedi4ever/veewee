require 'veewee/config'

require 'logger'

module Veewee

  # Represents a single Veewee environment. A "Veewee environment" is
  # defined as basically a folder with a "Veeweefile". This class allows
  # access to the VMs, CLI, etc. all in the scope of this environment
  class Environment

    # The `cwd` that this environment represents
    attr_reader :cwd

    # The valid name for a Mccloudfile for this environment
    attr_reader :veeweefile_name

    # The {UI} Object to communicate with the outside world
    attr_writer :ui

    # The configuration as loaded by the Mccloudfile
    attr_accessor :config

#    attr_accessor :providers


    def initialize(options=nil)
      options = {
        :cwd => nil,
        :veeweefile_name => nil}.merge(options || {})

      # Set the default working directory to look for the Veeweefile
      options[:veeweefile_name] ||=["Veeweefile"]

      logger.info("environment") { "Environment initialized (#{self})" }
      logger.info("environment") { " - cwd : #{cwd}" }

      options.each do |key, value|
        instance_variable_set("@#{key}".to_sym, options[key])
      end

      return self
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
        @config.load_definitions
        @ui.info "Loaded #{@config.builders.length} builders + #{@config.templates.length} templates +  #{@config.definitions.length} definitions "

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
      #     env.cli("package", "--veeweefile", "Mccloudfile")
      #
      def cli(*args)
        CLI.start(args.flatten, :env => self)
      end

      def resource
        "veewee"
      end

      # Accesses the logger for Vagrant. This logger is a _detailed_
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
