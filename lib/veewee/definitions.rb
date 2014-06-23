require 'grit'
require 'veewee/definition'
require 'veewee/templates'
require 'veewee/template'
require 'erb'

module Veewee
  class Definitions

    attr_accessor :env

    def initialize(env)
      @env = env
      @definitions = {}
      return self
    end


    def [](name)
      if @definitions[name].nil?
        begin
          @definitions[name] = Veewee::Definition.load(name, env)
        rescue Veewee::DefinitionNotExist
          return nil
        end
      end
      @definitions[name]
    end

    # Fetch all definitions
    def each(&block)
      definitions = Hash.new

      env.logger.debug("[Definition] Searching #{env.definition_dir} for definitions:")
      subdirs = Dir.glob("#{env.definition_dir}/*")

      subdirs.each do |sub|
        name = File.basename(sub)
        env.logger.debug("[Definition] possible definition '#{name}' found")
        begin
          definitions[name] = Veewee::Definition.load(name, env)
        rescue Veewee::DefinitionError => ex
          env.logger.debug("[Definition] failed to load definition from directory '#{name}' #{ex}")
        end
      end

      if definitions.length == 0
        env.logger.debug("[Definition] no definitions found")
      end

      definitions.each(&block)
    end

    # This function 'defines'/'clones'/'instantiates a template:
    # It copies from a template dir with template_name
    #           to a new definition dir with definition_name
    #
    # Options are : :force => true to overwrite an existing definition
    #
    # Returns definition object
    def define(definition_name, template_name, options = {})

      # Default is not to overwrite
      options = { 'force' => false }.merge(options)

      env.logger.debug("Forceflag : #{options['force']}")

      git_template = false
      # Check if the template is a git repo
      if template_name.start_with?("git://", "git+ssh://", "git+http://")
        git_template = true
      end

      # Check if template exists
      template = env.templates[template_name]
      if template.nil? and ! git_template
        env.logger.fatal("Template '#{template_name}' does not exist")
        raise Veewee::TemplateError, "Template '#{template_name}' does not exist"
      else
        env.logger.debug("Template '#{template_name}' exists")
      end

      create_definition_dir_if_needed

      # Check if definition does not exist
      definition = env.definitions[definition_name]
      unless definition.nil?
        env.logger.debug("Definition '#{definition_name}' exists")
        if options['force'] == true
          self.undefine(definition_name, options)
        else
          raise Veewee::DefinitionError, "Definition #{definition_name} already exists and no force option was given"
        end
      end

      env.logger.info("Creating definition #{definition_name} in directory '#{env.definition_dir}' ")
      dst_dir = "#{File.join(env.definition_dir, definition_name)}"
      FileUtils.mkdir(dst_dir)
      env.logger.debug("Definition Directory '#{File.join(env.definition_dir, definition_name)}' succesfuly created")

      # Start copying/cloning the directory of the template to the definition directory
      if (git_template)
        begin
          env.logger.info("Starting git clone #{template_name} #{dst_dir}")
          g = Grit::Git.new(dst_dir)
          g.clone({ :timeout => false }, template_name, dst_dir)
        rescue Exception => ex
          err = "git clone #{template_name} #{dst_dir} failed: #{ex}"
          env.logger.fatal(err)
          raise Veewee::DefinitionError, err
        end
      else
        begin
          env.logger.debug("Starting copy '#{template.path}' to '#{dst_dir}'")
          FileUtils.cp_r(template.path + "/.", dst_dir, :preserve => true)
          env.logger.debug("Copy '#{template.path}' to '#{dst_dir}' succesful")
        rescue Exception => ex
          env.logger.fatal("Copy '#{template.path}' to #{dst_dir}' failed: #{ex}")
          raise Veewee::Error, "Copy '#{template.path}' to #{dst_dir}' failed: #{ex}"
        end
      end

      # If the template includes a NOTICE.erb or NOTICE.txt file, display it to the user
      # .erb file takes priority, then .txt
      notice_erb = File.join(dst_dir, 'NOTICE.erb')
      notice_txt = File.join(dst_dir, 'NOTICE.txt')
      if File.exist?(notice_erb)
        template = File.read(notice_erb)
        text = ERB.new(template).result(binding)
      elsif File.exist?(notice_txt)
        text = File.read(notice_txt)
      end

      if text
        env.ui.warn("Template #{template_name} includes this NOTICE text you should first read:\n")
        env.ui.info("#{text}\n")
      end

      definition = env.definitions[definition_name]
      return definition
    end


    # This function undefines/removes the definition by removing the directoy with definition_name
    # under env.definition_dir
    def undefine(definition_name, options = {})
      definition = env.definitions[definition_name]
      unless definition.nil?

        #TODO: Needs to be more defensive!!
        env.logger.debug("[Undefine] About to remove '#{definition.path} for '#{definition_name}'")
        begin
          if File.exists?(File.join(definition.path, "definition.rb"))
            FileUtils.rm_rf(definition.path)
          else
            env.logger.fatal("Aborting delete: The directory definition.path does not contain a definition.rb file")
            raise Veewee::DefinitionError, "Aborting delete: The directory definition.path does not contain a definition.rb file"
          end
        rescue Exception => ex
          env.logger.fatal("Removing '#{definition.path} for '#{definition_name}' failed: #{ex}")
          raise Veewee::Error, "Removing '#{definition.path }for '#{definition_name}' failed: #{ex}"
        end
        env.logger.debug("Removing '#{definition.path} for '#{definition_name}' succesful")
      else
        raise Veewee::DefinitionError, "Definition '#{definition_name}' does not exist"
      end
    end

    def create_definition_dir_if_needed
      # Check if definition_dir already exists
      unless File.exists?(env.definition_dir)
        env.logger.debug("Creating definition base directory '#{env.definition_dir}' ")
        FileUtils.mkdir(env.definition_dir)
        env.logger.debug("Definition base directory '#{env.definition_dir}' succesfuly created")
      end

      if File.writable?(env.definition_dir)
        env.logger.debug("DefinitionDir '#{env.definition_dir}' is writable")
        if File.exists?("#{env.definition_dir}")
          env.logger.debug("DefinitionDir '#{env.definition_dir}' already exists")
        else
          env.logger.debug("DefinitionDir '#{env.definition_dir}' does not exist, creating it")
          FileUtils.mkdir(definition_dir)
          env.logger.debug("DefinitionDir '#{env.definition_dir}' succesfuly created")
        end
      else
        env.logger.fatal("DefinitionDir '#{env.definition_dir}' is not writable")
        raise Veewee::Error, "DefinitionDir '#{env.definition_dir}' is not writable"
      end
    end

  end
end
