require 'veewee/config'

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
    # - :definition_path  : paths to look for definitions
    # - :definition_dir   : where new definition will be created
    # - :template_path    : paths that contains the template definitions that come with the veewee gem, defaults to the path relative to the gemfiles
    # - :iso_dir         : directory to look for iso files, defaults to $environment_dir/iso
    # - :validation_dir  : directory that contains a list of validation tests, that can be run after building a box
    # - :tmp_dir         : directory that will be used for creating temporary files, needs to be rewritable, default to $environment_dir/tmp

    attr_accessor :template_path,:definition_path, :definition_dir

    attr_accessor :iso_dir,:tmp_dir

    # The {UI} Object to communicate with the outside world
    attr_writer :ui

    # The configuration as loaded
    attr_accessor :config

    def initialize(options={})

      defaults={
        :cwd => Dir.pwd,
        :veewee_filename => "Veeweefile",
        :loglevel => :info,
        :definition_path => [File.join(Dir.pwd,"definitions")],
        :definition_dir => File.join(Dir.pwd,"definitions"),
        :template_path => [File.expand_path(File.join(File.dirname(__FILE__),"..","..",'templates')),"templates"],
        :iso_dir => File.join(Dir.pwd,"iso"),
        :validation_dir => File.join(File.expand_path(File.join(File.dirname(__FILE__),"..","..")),"validation"),
        :tmp_dir => File.join(Dir.pwd,"tmp")
      }

      options = defaults.merge(options)

      logger.info("environment") { "Environment initialized (#{self})" }

      options.each do |key, value|
        instance_variable_set("@#{key}".to_sym, options[key])
        logger.info("environment") { " - #{key} : #{options[key]}" }

      end
      return self
    end


    #---------------------------------------------------------------
    # Retrieval Methods
    #---------------------------------------------------------------

    # Traverses path to see which exist or not
    # and checks if a definition.rb is available
    def valid_paths(paths)
      valid_paths=paths.collect { |path|
        if File.exists?(path) && File.directory?(path)
          logger.info "Definition path #{path} exists"
          File.expand_path(path)
        else
          logger.info "Definition path #{path} does not exist, skipping"
          nil
        end
      }
      return valid_paths.compact
    end

    # This function retrieves all the templates given the @template_dir in the current Environment object
    # A valid template has to contain the file definition.rb
    # The name of the template is the name of the parent directory of the definition.rb file
    #
    # returns a hash of 'template name' => 'path'
    def get_template_paths

      templates=Hash.new

      valid_paths(template_path).each do |template_dir|

      logger.debug("[Template] Searching #{template_dir} for templates")

      subdirs=Dir.glob("#{template_dir}/*")
      subdirs.each do |sub|
        if File.directory?("#{sub}")
          definition=Dir.glob("#{sub}/definition.rb")
          if definition.length!=0
            name=sub.sub(/#{template_dir}\//,'')
              logger.debug("[Template] template '#{name}' found")
            templates[name]=File.join(template_dir,name)
          end
        end
      end
    end

      return templates
    end

     # This function returns a hash of names of all the definitions that are in the @definition_dir,
     # given the @definition_dir in the current Environment object
     # The name of the definition is the name of a sub-directory in the @definition_dir
     def get_definition_paths

       definitions=Hash.new

       valid_paths(definition_path).each do |definition_dir|

       logger.debug("[Definition] Searching #{definition_dir} for definitions:")

       subdirs=Dir.glob("#{definition_dir}/*")
       subdirs.each do |sub|
         name=File.basename(sub)
         logger.debug("[Definition] definition '#{name}' found")
         definitions[name]=File.join(definition_dir,name)
       end
      end
       logger.debug("[Definition] no definitions found") if definitions.length==0

       return definitions
     end

     # Based on the definition_dir set in the current Environment object
      # it will load the definition based on the name
      #
      # returns a Veewee::Definition
      def get_definition(name)
        definition=Veewee::Definition.load(name,self)
        return definition
      end

     # This function 'defines'/'clones'/'instantiates a template
      # by copying the template directory to a directory with the definitionname under the @defintion_dir
      # Options are : :force => true to overwrite an existing definition
      #
      # Returns nothing
      def define(definition_name,template_name,define_options = {})
        # Default is not to overwrite
        define_options = {'force' => false}.merge(define_options)

        logger.debug("Forceflag : #{define_options['force']}")

        # Check if template exists
        template_exists=get_template_paths.has_key?(template_name)
        template_dir=get_template_paths[template_name]

        unless template_exists
          logger.fatal("Template '#{template_name}' does not exist")
          exit -1
        else
          logger.debug("Template '#{template_name}' exists")
        end

        # Check if definition exists
        definition_exists=get_definition_paths.has_key?(definition_name)
        definition_dir=get_definition_paths[definition_name]

        if definition_exists
          logger.debug("Definition '#{definition_name}' already exists")

          if !define_options['force']
            logger.fatal("No force was specified, bailing out")
            exit -1
          else
            logger.debug("Force option specified, cleaning existing directory")
            undefine(definition_name)
          end

        else
          logger.debug("Definition '#{definition_name}' does not yet exist")
        end

        unless File.exists?(@definition_dir)
          logger.debug("Creating definition base directory '#{@definition_dir}' ")
          FileUtils.mkdir(@definition_dir)
          logger.debug("Definition base directory '#{@definition_dir}' succesfuly created")
        end

        if File.writable?(@definition_dir)
          logger.debug("DefinitionDir '#{@definition_dir}' is writable")
          if File.exists?("#{@definition_dir}")
            logger.debug("DefinitionDir '#{@definition_dir}' already exists")
          else
            logger.debug("DefinitionDir '#{@definition_dir}' does not exist, creating it")
            FileUtils.mkdir(definition_dir)
            logger.debug("DefinitionDir '#{@definition_dir}' succesfuly created")
          end
          logger.debug("Creating definition #{definition_name} in directory '#{@definition_dir}' ")
          FileUtils.mkdir(File.join(@definition_dir,definition_name))
          logger.debug("Definition Directory '#{File.join(@definition_dir,definition_name)}' succesfuly created")

        else
          logger.fatal("DefinitionDir '#{definition_dir}' is not writable")
          exit -1
        end

        # Start copying/cloning the directory of the template to the definition directory
        begin
          logger.debug("Starting copy '#{template_dir}' to '#{File.join(@definition_dir,definition_name)}'")
          FileUtils.cp_r(template_dir+"/.","#{File.join(@definition_dir,definition_name)}")
          logger.debug("Copy '#{template_dir}' to '#{File.join(@definition_dir,definition_name)}' succesfull")
        rescue Exception => ex
          logger.fatal("Copy '#{template_dir}' to #{File.join(@definition_dir,definition_name)}' failed: #{ex}")
          exit -1
        end
      end


      # This function undefines/removes the definition by removing the directoy with definition_name
      # under @definition_dir
      def undefine(definition_name,undefine_options = {})
        definition_dir=get_definition_paths[definition_name]
        unless definition_dir.nil?
          #TODO: Needs to be more defensive!!
          logger.debug("[Undefine] About to remove '#{definition_dir} for '#{definition_name}'")
          begin
            FileUtils.rm_rf(definition_dir)
          rescue Exception => ex
            logger.fatal("Removing '#{definition_dir} for '#{definition_name}' failed")
            exit -1
          end
          logger.debug("Removing '#{definition_dir} for '#{definition_name}' succesful")
        else
          logger.fatal("Definition '#{definition_name}' does not exist")
          exit -1
        end
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

        @config.load_builders

        @ui.info "Loaded #{@config.builders.length} builders"

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
