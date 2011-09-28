module Veewee
  module Command
    class Vmfusion< Veewee::Command::GroupBase

      register "fusion", "Subcommand for Vmware fusion"
      desc "build [TEMPLATE_NAME] [BOX_NAME]", "Build box"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "force the build"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      method_option :nogui,:type => :boolean , :default => false, :aliases => "-n", :desc => "no gui"
      method_option :auto,:type => :boolean , :default => false, :aliases => "-a", :desc => "auto answers"      
      method_option :postinstall_include, :type => :array, :default => [], :aliases => "-i", :desc => "patterns of postinstall filenames to additionally include"
      method_option :postinstall_exclude, :type => :array, :default => [], :aliases => "-e", :desc => "patterns of postinstall filenames to exclude"
      
      def build(definition_name,box_name=nil)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.config.builders["vmfusion"].build(definition_name,box_name,options)       
        
#        venv.ui.info "#{box_name} was build succesfully. "
#        venv.ui.info ""
#        venv.ui.info "Now you can: "
#        venv.ui.info "- verify your box by running              : veewee fusion validate #{definition_name}"
#        venv.ui.info "- export your vm to a .box fileby running : veewee fusion export   #{definition_name}"

      end

      desc "destroy [BOXNAME]", "Destroys the virtualmachine that was build"
      def destroy(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.config.builders["vmfusion"].get_box(box_name).destroy
      end

      desc "define [BOXNAME] [TEMPLATE]", "Define a new basebox starting from a template"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "overwrite the definition"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def define(definition_name, template_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.define(definition_name,template_name,options)
        env.ui.info "The basebox '#{definition_name}' has been succesfully created from the template '#{template_name}'"
        env.ui.info "You can now edit the definition files stored in definitions/#{definition_name} or build the box with:"
        env.ui.info "veewee fusion build '#{definition_name}'"
      end

      desc "undefine [BOXNAME]", "Removes the definition of a basebox "
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def undefine(definition_name)
        env.ui.info "Removing definition #{definition_name}" , :prefix => false
        begin
          venv=Veewee::Environment.new(options)
          venv.ui=env.ui
          venv.undefine(definition_name,options)
          env.ui.info "Definition #{definition_name} succesfully removed",:prefix => false
        rescue Error => ex
          env.ui.error "#{ex}" , :prefix => false
          exit -1
        end
      end
      
      desc "validate [NAME]", "Validates a box against vmfusion compliancy rules"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging" 
      def validate(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.config.builders["vmfusion"].validate_vmfusion(box_name,options)
      end
      

      desc "ostypes", "List the available Operating System types"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging" 
      def ostypes
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.list_ostypes
      end
      
      desc "export [NAME]", "Exports the basebox to the ova format"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def export(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.config.builders["vmfusion"].get_box(box_name).export_ova(options)
      end


      desc "templates", "List the currently available templates"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def templates
        env.ui.info "The following templates are available:",:prefix => false
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.get_template_paths.keys.each do |name|
          env.ui.info "veewee fusion define '<box_name>' '#{name}'",:prefix => false
        end
      end

      desc "list", "Lists all defined boxes"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def list
        env.ui.info "The following local definitions are available:",:prefix => false
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.get_definition_paths.keys.each do |name|
          env.ui.info "- #{name}"
        end
      end


    end

  end
end
