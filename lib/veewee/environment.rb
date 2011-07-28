require 'ansi/logger'
require 'tempfile'

require 'veewee/error'
require 'veewee/definition'
require 'veewee/builderfactory'

module Veewee  
  
  # This class represents the environment used for building boxes, it's mostly pointing to the correct directories
  # so that it finds the templates, definitions and other parts
  class Environment

    attr_accessor :environment_dir
    attr_accessor :definition_dir
    attr_accessor :iso_dir
    attr_accessor :tmp_dir
    attr_accessor :box_dir
    attr_accessor :veewee_dir
    attr_accessor :template_dir
    attr_accessor :validation_dir
    attr_accessor :log
    
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
    #
    # returns a new Veewee::Environment
    def initialize(settings={})
      
      @log=ANSI::Logger.new(settings['log_file']||STDOUT)
      level=settings['log_level']||'INFO'
      @log.level=Object.const_get('ANSI').const_get('Logger').const_get(level.upcase)
      if settings['log_file'].nil?
        @log.formatter do |severity, timestamp, progname, msg|
          #  "#{progname}@#{timestamp} - #{severity}::#{msg}"
          "#{msg}\n"
        end
      else
        @log.ansicolor=false
      end

      @log.debug("[Environment] Initalizing new Veewee Environment:")
            
      @environment_dir=settings[:environment_dir]||Dir.pwd
      @definition_dir=settings[:definition_dir]||File.join(@environment_dir,"definitions")
      @iso_dir=settings[:iso_dir]||File.join(@environment_dir,"iso")
      @box_dir=settings[:box_dir]||File.join(@environment_dir,"boxes")
      @veewee_dir=File.expand_path(File.join(File.dirname(__FILE__),"..",".."))
      @validation_dir=settings[:validation_dir]|| File.join(@veewee_dir,"validation")
      @template_dir=settings[:template_dir]||File.expand_path(File.join(File.dirname(__FILE__),"..","..", "templates"))
      @tmp_dir=settings[:tmp_dir]||File.join(@environment_dir,"tmp")

      # Output the variables for debugging
      arguments=[:environment_dir, :definition_dir, :iso_dir, :box_dir,:veewee_dir, :validation_dir, :template_dir, :tmp_dir]
      arguments.each do |key|
        @log.debug("[Environment] - #{key}: #{self.instance_variable_get("@"+key.to_s)}")
      end
           
      return self
    end
       
    
    # Based on the definition_dir set in the current Environment object
    # it will load the definition based on the name 
    #
    # returns a Veewee::Definition
    def get_definition(name)
      # This should be locked (it loads the declare in a class var and then reads it into this environment)
      @log.debug("[Definition - '#{name}'] Trying to load from directory #{@definition_dir}")
      begin
        definition=Veewee::Definition.load(name,@definition_dir)
        @log.debug("[Definition - '#{name}'] Succesfully loaded")
      rescue Exception => ex
        @log.fatal("[Definition - '#{name}'] Loading failed from #{@definition_dir} : #{ex}")
      end
      return definition
    end
     
    
    # This function retrieves all the templates given the @template_dir in the current Environment object
    # A valid template has to contain the file definition.rb
    # The name of the template is the name of the parent directory of the definition.rb file
    #
    # returns a sorted Array of template names 
    def get_templates
      template_names=Array.new
      
      @log.debug("[Template] Searching #{@template_dir} for templates")
      
      subdirs=Dir.glob("#{@template_dir}/*")
      subdirs.each do |sub|
        if File.directory?("#{sub}")
          definition=Dir.glob("#{sub}/definition.rb")
          if definition.length!=0
            name=sub.sub(/#{@template_dir}\//,'')
            @log.debug("[Template] template '#{name}' found")           
            template_names << name
          end
        end
      end
      
      return template_names.sort
    end
    
     
    
    # This function returns a sorted Array of names of all the definitions that are in the @definition_dir, 
    # given the @definition_dir in the current Environment object
    # The name of the definition is the name of a sub-directory in the @definition_dir
    def get_definitions
      definition_names=Array.new
      
      @log.debug("[Definition] Searching #{@definition_dir} for definitions:")
      
      subdirs=Dir.glob("#{@definition_dir}/*")
      subdirs.each do |sub|
        name=File.basename(sub)
        @log.debug("[Definition] definition '#{name}' found")
        definition_names << name
      end

      @log.debug("[Definition] no definitions found") if definition_names.length==0
      
      return definition_names.sort
    end 
    

    # This function returns a builder, of type Veewee::Builder that can manage boxes 
    # The generated object is a class from the builder_type specified and has a link to this environment
    def get_builder(builder_type,builder_options={})
      
      @log.debug("[Builder] Requesting a builder of type '#{builder_type}' with options:")
      builder_options.each do |key,value|
        @log.debug("[Builder] - #{key}: #{value}")
      end
      
      builder=Veewee::BuilderFactory.instantiate(builder_type,builder_options,self)    
      return builder
    end  
  
  
    # This function 'defines'/'clones'/'instantiates a template
    # by copying the template directory to a directory with the definitionname under the @defintion_dir
    # Options are : :force => true to overwrite an existing definition
    #
    # Returns nothing
    def define(definition_name,template_name,define_options = {})
        # Default is not to overwrite 
        define_options = {'force' => false}.merge(define_options)
      
        @log.debug("Forceflag : #{define_options['force']}")
        
        # Check if template exists
        template_exists=get_templates.include?(template_name)
        template_dir=File.join(@template_dir,template_name,'.')
        
        unless template_exists
          @log.fatal("Template '#{template_name}' does not exist")
          raise TemplateError, "Template '#{template_name}' does not exist"
        else
          @log.debug("Template '#{template_name}' exists")
        end

        # Check if definition exists
        definition_exists=get_definitions.include?(definition_name)
        definition_dir=File.join(@definition_dir,definition_name)
        
        if definition_exists
          @log.debug("Definition '#{definition_name}' already exists")
          
          if !define_options['force'] 
            @log.fatal("No force was specified, bailing out")
            raise DefinitionError, "Definition '#{definition_name}' already exists"
          else
            @log.debug("Force option specified, cleaning existing directory")
            undefine(definition_name)
          end
          
        else
          @log.debug("Definition '#{definition_name}' does not yet exist")

        end

        # Check if writeable
        if File.writable?(@definition_dir)
          @log.debug("DefinitionDir '#{@definition_dir}' is writable")
          if File.exists?("#{@definition_dir}")
            @log.debug("DefinitionDir '#{@definition_dir}' already exists")
          else
            @log.debug("DefinitionDir '#{@definition_dir}' does not exist, creating it")            
            FileUtils.mkdir(@definition_dir)    
            @log.debug("DefinitionDir '#{@definition_dir}' succesfuly created")            
          end
          @log.debug("Creating definition #{definition_name} in directory '#{definition_dir}' ")            
          FileUtils.mkdir(File.join(@definition_dir,definition_name))
          @log.debug("Definition Directory '#{definition_dir}' succesfuly created")            

        else
          @log.fatal("DefinitionDir '#{@definition_dir}' is not writable")
          raise DefinitionDirError, "DefinitionDirectory #{@definition_dir} is not writable"
        end

        # Start copying/cloning the directory of the template to the definition directory
        begin
          @log.debug("Starting copy '#{template_dir}' to '#{definition_dir}'")          
          FileUtils.cp_r(template_dir,definition_dir)
          @log.debug("Copy '#{template_dir}' to '#{definition_dir}' succesful")
        rescue Exception => ex
          @log.fatal("Copy '#{template_dir}' to '#{definition_dir}' failed: #{ex}")
          raise DefinitionError, "Copy '#{template_dir}' to '#{definition_dir}' failed: #{ex}"
        end
    end



    # This function undefines/removes the definition by removing the directoy with definition_name
    # under @definition_dir
    def undefine(definition_name,undefine_options = {})
        definition_dir=File.join(@definition_dir,definition_name)
        if File.directory?(definition_dir)
          #TODO: Needs to be more defensive!!
          @log.debug("[Undefine] About to remove '#{definition_dir} for '#{definition_name}'")
          begin
            FileUtils.rm_rf(definition_dir)
          rescue Exception => ex
            @log.fatal("[Undefine] Removing '#{definition_dir} for '#{definition_name}' failed")
          end
          @log.debug("[Undefine] Removing '#{definition_dir} for '#{definition_name}' succesful")
        else
          @log.fatal("[Undefine] Directory '#{definition_dir} for '#{definition_name}' does not exist")
          raise DefinitionError, "Can not undefine '#{definition_name}': '#{definition_dir}' does not exist"          
        end
    end

  end #End Class
end #End Module
