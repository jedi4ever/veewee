require 'ostruct'

module Veewee
  class Definition

    attr_accessor :name
    attr_accessor :env
    
    attr_accessor :cpu_count,:memory_size,:iso_file
    attr_accessor :disk_size, :disk_format
    
    attr_accessor :os_typ_id
    
    attr_accessor :boot_wait,:boot_cmd_sequence
    
    attr_accessor :kickstart_port,:kickstart_ip,:kickstart_timeout, :kickstart_file

    attr_accessor :ssh_login_timeout, :ssh_user , :ssh_password, :ssh_key, :ssh_host_port, :ssh_guest_port 
    
    attr_accessor :sudo_cmd
    attr_accessor :shutdown_cmd

    attr_accessor :postinstall_files, :postinstall_timeout
    
    attr_accessor :floppy_files
    
    attr_accessor :path
    
    attr_accessor :os_type_id,:use_hw_virt_ext,:use_pae,:hostiocache
    
    attr_accessor :iso_dowload_timeout, :iso_src,:iso_md5 ,:iso_download_instructions
    
    def initialize(name,env)

      @name=name
      @env=env

      # Default is 1 CPU + 256 Mem of memory
      @cpu_count='1' ; @memory_size='256';      
      
      # Default there is no ISO file mounted
      @iso_file = nil, @iso_src = nil ; @iso_md5 = nil ; @iso_download_timeout=1000 ; @iso_download_instructions = nil
      
      # Default is no floppy mounted
      @floppy_files = nil
      
      # Default there are no post install files
      @postinstall_files=[]; @postinstall_timeout = 10000;

      @iso_file=""
      @disk_size = '10240'; @disk_format = 'VDI'

#        :hostiocache => 'off' ,
#        :os_type_id => 'Ubuntu',


#        :boot_wait => "10", :boot_cmd_sequence => [ "boot"],
#        :kickstart_port => "7122", :kickstart_ip => "127.0.0.1", :kickstart_timeout => 10000,#

#        :ssh_login_timeout => "10000", :ssh_user => "vagrant", :ssh_password => "vagrant",:ssh_key => "",
#        :ssh_host_port => "2222", :ssh_guest_port => "22", :sudo_cmd => "echo '%p'|sudo -S sh '%f'",

#       :shutdown_cmd => "shutdown -h now",


#        :kickstart_file => nil,

#      }

#      options=defaults.merge(options)


    end
    
    
    # Based on the definition_dir set in the current Environment object
     # it will load the definition based on the name
     #
     # returns a Veewee::Definition
     def self.get_definition(name)

       logger.debug("[Definition - '#{name}'] Trying to load from directory #{@definition_dir}")
       begin
         definition=Veewee::Definition.load(name,@definition_dir,logger)
         logger.debug("[Definition - '#{name}'] Succesfully loaded")
       rescue Exception => ex
         logger.fatal("[Definition - '#{name}'] Loading failed from #{@definition_dir} : #{ex}")
       end
       return definition
     end


     # This function retrieves all the templates given the @template_dir in the current Environment object
     # A valid template has to contain the file definition.rb
     # The name of the template is the name of the parent directory of the definition.rb file
     #
     # returns a sorted Array of template names
     def self.get_templates
       template_names=Array.new

       logger.debug("[Template] Searching #{@template_dir} for templates")

       subdirs=Dir.glob("#{@template_dir}/*")
       subdirs.each do |sub|
         if File.directory?("#{sub}")
           definition=Dir.glob("#{sub}/definition.rb")
           if definition.length!=0
             name=sub.sub(/#{@template_dir}\//,'')
               logger.debug("[Template] template '#{name}' found")
             template_names << name
           end
         end
       end

       return template_names.sort
     end



     # This function returns a sorted Array of names of all the definitions that are in the @definition_dir,
     # given the @definition_dir in the current Environment object
     # The name of the definition is the name of a sub-directory in the @definition_dir
     def self.get_definitions
       definition_names=Array.new

       logger.debug("[Definition] Searching #{@definition_dir} for definitions:")

       subdirs=Dir.glob("#{@definition_dir}/*")
       subdirs.each do |sub|
         name=File.basename(sub)
         logger.debug("[Definition] definition '#{name}' found")
         definition_names << name
       end

       logger.debug("[Definition] no definitions found") if definition_names.length==0

       return definition_names.sort
     end

     # This function 'defines'/'clones'/'instantiates a template
     # by copying the template directory to a directory with the definitionname under the @defintion_dir
     # Options are : :force => true to overwrite an existing definition
     #
     # Returns nothing
     def self.define(definition_name,template_name,define_options = {})
       # Default is not to overwrite
       define_options = {'force' => false}.merge(define_options)

       logger.debug("Forceflag : #{define_options['force']}")

       # Check if template exists
       template_exists=get_templates.include?(template_name)
       template_dir=File.join(@template_dir,template_name,'.')

       unless template_exists
         logger.fatal("Template '#{template_name}' does not exist")
         raise TemplateError, "Template '#{template_name}' does not exist"
       else
         logger.debug("Template '#{template_name}' exists")
       end

       # Check if definition exists
       definition_exists=get_definitions.include?(definition_name)
       definition_dir=File.join(@definition_dir,definition_name)

       if definition_exists
         logger.debug("Definition '#{definition_name}' already exists")

         if !define_options['force']
           logger.fatal("No force was specified, bailing out")
           raise DefinitionError, "Definition '#{definition_name}' already exists"
         else
           logger.debug("Force option specified, cleaning existing directory")
           undefine(definition_name)
         end

       else
         logger.debug("Definition '#{definition_name}' does not yet exist")

       end

       # Check if writeable
       if File.writable?(@definition_dir)
         logger.debug("DefinitionDir '#{@definition_dir}' is writable")
         if File.exists?("#{@definition_dir}")
           logger.debug("DefinitionDir '#{@definition_dir}' already exists")
         else
           logger.debug("DefinitionDir '#{@definition_dir}' does not exist, creating it")
           FileUtils.mkdir(@definition_dir)
           logger.debug("DefinitionDir '#{@definition_dir}' succesfuly created")
         end
         logger.debug("Creating definition #{definition_name} in directory '#{definition_dir}' ")
         FileUtils.mkdir(File.join(@definition_dir,definition_name))
         logger.debug("Definition Directory '#{definition_dir}' succesfuly created")

       else
         logger.fatal("DefinitionDir '#{@definition_dir}' is not writable")
         raise DefinitionDirError, "DefinitionDirectory #{@definition_dir} is not writable"
       end

       # Start copying/cloning the directory of the template to the definition directory
       begin
         logger.debug("Starting copy '#{template_dir}' to '#{definition_dir}'")
         FileUtils.cp_r(template_dir,definition_dir)
         logger.debug("Copy '#{template_dir}' to '#{definition_dir}' succesful")
       rescue Exception => ex
         logger.fatal("Copy '#{template_dir}' to '#{definition_dir}' failed: #{ex}")
         raise DefinitionError, "Copy '#{template_dir}' to '#{definition_dir}' failed: #{ex}"
       end
     end


     # This function undefines/removes the definition by removing the directoy with definition_name
     # under @definition_dir
     def self.undefine(definition_name,undefine_options = {})
       definition_dir=File.join(@definition_dir,definition_name)
       if File.directory?(definition_dir)
         #TODO: Needs to be more defensive!!
         logger.debug("[Undefine] About to remove '#{definition_dir} for '#{definition_name}'")
         begin
           FileUtils.rm_rf(definition_dir)
         rescue Exception => ex
           logger.fatal("[Undefine] Removing '#{definition_dir} for '#{definition_name}' failed")
         end
         logger.debug("[Undefine] Removing '#{definition_dir} for '#{definition_name}' succesful")
       else
         logger.fatal("[Undefine] Directory '#{definition_dir} for '#{definition_name}' does not exist")
         raise DefinitionError, "Can not undefine '#{definition_name}': '#{definition_dir}' does not exist"
       end
     end
     
    def method_missing(m, *args, &block)
     env.logger.info "There's no attribute #{m} defined for builder #{@name}-- ignoring it"
    end


  end #End Class
end #End Module
