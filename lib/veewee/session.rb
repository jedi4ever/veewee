require 'veewee/definition'
require 'veewee/provider/virtualbox'
require 'tempfile'
require 'virtualbox'

module Veewee  
  
  class Session

    attr_accessor :session_dir
    attr_accessor :definition_dir
    attr_accessor :iso_dir
    attr_accessor :tmp_dir
    attr_accessor :box_dir


    attr_accessor :veewee_dir
    attr_accessor :template_dir
    attr_accessor :validation_dir

    @loaded_definition=nil 
    def self.get_loaded_definition
      @loaded_definition
    end
    
    def initialize(settings={})
      @session_dir=settings[:session_dir]||Dir.pwd
      @definition_dir=settings[:definition_dir]||File.join(@session_dir,"definitions")
      @iso_dir=settings[:iso_dir]||File.join(@session_dir,"iso")
      @box_dir=settings[:box_dir]||File.join(@session_dir,"boxes")
      @tmp_dir=settings[:tmp_dir]||File.join(@session_dir,"tmp")
      @validation_dir=settings[:validation_dir]||File.expand_path(File.join(File.dirname(__FILE__),"..","..", "validation"))
      @template_dir=settings[:template_dir]||File.expand_path(File.join(File.dirname(__FILE__),"..","..", "templates"))     
      return self
    end
    
    def get_definition(name)
      # This should be locked (it loads the declare in a class var and then reads it into this session)
      definition=Veewee::Definition.load(name,@definition_dir)
      return definition
    end


    # For backwards compatible reasons
    # Shoud not be called directly
    def self.declare(options)
      @loaded_definition=options
    end

    def self.get_provider(name)
      Object.const_get("Veewee").const_get("Virtualbox")
    end
    
    def build(name,definition)
      options={}
      defaults={ :provider_type => "Virtualbox" }
      options=defaults.merge(options)
      provider=Veewee::Session.get_provider(options[:provider_type]).new(name,definition,self)
      
      #verify_postinstalls
      #verify it all
      

      provider.build
    end
    
    def destroy(name,definition)
      options={}
      defaults={ :provider_type => "Virtualbox" }
      options=defaults.merge(options)
      provider=Veewee::Session.get_provider(options[:provider_type]).new(name,definition,self)      
      provider.destroy_vm
    end
    
      def self.define(boxname,template_name,options = {})
        #Check if template_name exists

        options = {  "force" => false, "format" => "vagrant" }.merge(options)

        if File.directory?(File.join(@template_dir,template_name))
        else
          puts "This template can not be found, use vagrant basebox templates to list all templates"
          exit
        end
        if !File.exists?(@definition_dir)
          FileUtils.mkdir(@definition_dir)
        end


        if File.directory?(File.join(@definition_dir,boxname))
          if !options["force"]
            puts "The definition for #{boxname} already exists. Use --force to overwrite"
            exit
          end
        else
          FileUtils.mkdir(File.join(@definition_dir,boxname))
        end
<<
        FileUtils.cp_r(File.join(@template_dir,template_name,'.'),File.join(@definition_dir,boxname))
        puts "The basebox '#{boxname}' has been succesfully created from the template ''#{template_name}'"
        puts "You can now edit the definition files stored in definitions/#{boxname}"
        puts "or build the box with:"
        if (options["format"]=='vagrant') 
          puts "vagrant basebox build '#{boxname}'"
        end
        if (options["format"]=='veewee')
          puts "veewee  build '#{boxname}'"
        end

      end

      def self.undefine(boxname)
        name_dir=File.join(@definition_dir,boxname)
        if File.directory?(name_dir)
          #TODO: Needs to be more defensive!!
          puts "Removing definition #{boxname}"
          FileUtils.rm_rf(name_dir)
        else
          puts "Can not undefine , definition #{boxname} does not exist"
          exit
        end
      end

      def self.list_templates( options = { :format => 'vagrant'})
        puts "The following templates are available:"
        subdirs=Dir.glob("#{@template_dir}/*")
        subdirs.each do |sub|
          if File.directory?("#{sub}")
            definition=Dir.glob("#{sub}/definition.rb")
            if definition.length!=0
              name=sub.sub(/#{@template_dir}\//,'')
              if (options[:format]=='vagrant') 
                puts "vagrant basebox define '<boxname>' '#{name}'"
              end
              if (options[:format]=='veewee')
                puts "veewee define '<boxname>' '#{name}'"
              end
            end
          end
        end
      end


      def self.list_boxes
        puts "Not yet implemented"
      end

      def self.list_definitions
        puts "The following defined baseboxes exist:"
        subdirs=Dir.glob("#{@definition_dir}/*")
        subdirs.each do |sub|
          puts "- "+File.basename(sub)
        end
      end

 


            def self.validate_box(boxname,options)
              require 'cucumber'

              require 'cucumber/rspec/disable_option_parser'
              require 'cucumber/cli/main'

              ENV['veewee_user']=options[:user]
              feature_path=File.join(File.dirname(__FILE__),"..","..","validation","vagrant.feature")

              features=Array.new
              features[0]=feature_path



              begin
                # The dup is to keep ARGV intact, so that tools like ruby-debug can respawn.
                failure = Cucumber::Cli::Main.execute(features.dup)
                Kernel.exit(failure ? 1 : 0)
              rescue SystemExit => e
                Kernel.exit(e.status)
              rescue Exception => e
                STDERR.puts("#{e.message} (#{e.class})")
                STDERR.puts(e.backtrace.join("\n"))
                Kernel.exit(1)
              end

            end

            def self.list_ostypes
              puts
              puts "Available os types:"
              VirtualBox::Global.global.lib.virtualbox.guest_os_types.collect { |os|
                puts "#{os.id}: #{os.description}"
              }      
            end


              end #End Class
            end #End Module
