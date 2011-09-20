require 'veewee'

module Veewee
  module Vagrant
    class Command < ::Vagrant::Command::GroupBase
      
      register "basebox", "Commands to manage baseboxes"
      desc "build [TEMPLATE_NAME] [BOX_NAME]", "Build box"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "force the build"
      def build(definition_name,box_name=nil)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.config.builders["virtualbox"].build(definition_name,box_name,options)
      end
      
      desc "destroy [BOXNAME]", "Destroys the virtualmachine that was build"
      def destroy(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.config.builders["virtualbox"].get_box(box_name).destroy
      end   

      desc "define [BOXNAME] [TEMPLATE]", "Define a new basebox starting from a template"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "overwrite the definition" 
      def define(definition_name, template_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        
        venv.define(definition_name,template_name,options)
        env.ui "The basebox '#{definition_name}' has been succesfully created from the template '#{template_name}'"
        env.ui "You can now edit the definition files stored in definitions/#{definition_name} or build the box with:"
        env.ui "vagrant basebox build '#{definition_name}'"
      end

      desc "undefine [BOXNAME]", "Removes the definition of a basebox "
      def undefine(definition_name)
        env.ui "Removing definition #{definition_name}"
        begin
          venv=Veewee::Environment.new(options)
          venv.ui=env.ui
          venv.undefine(definition_name,options)
          env.ui "Definition #{definition_name} succesfully removed"
        rescue Error => ex
          env.ui "#{ex}"
          exit -1
        end
      end   
   
      desc "templates", "List the currently available templates"
      def templates
        env.ui.info "The following templates are available:"
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        
        venv.get_template_paths.keys.each do |name|
          env.ui.info "vagrant basebox define '<box_name>' '#{name}'"
        end        
      end

      desc "list", "Lists all defined boxes"
      def list
        env.ui.info "The following local definitions are available:"
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        
        venv.get_definition_paths.keys.each do |name|
          env.ui.info "- #{name}"
        end
      end  

      desc "ostypes", "List the available Operating System types"
      method_option :log_level, :default => 'info', :desc => "info,warning,debug"
      method_option :log_file, :desc => "file to output log"
      def ostypes
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.list_ostypes
      end
            
            desc "validate [NAME]", "Validates a box against vagrant compliancy rules"
            
            def validate(box_name)
              venv=Veewee::Environment.new(options)
              venv.ui=env.ui
            
              venv.config.builders["virtualbox"].validate_vagrant(box_name,options)
            end

    desc "export [NAME]", "Exports the basebox to the vagrant box format" 
    def export(box_name)
      venv=Veewee::Environment.new(options)
      venv.ui=env.ui
      venv.config.builders["virtualbox"].export_vagrant(box_name,options)
    end 

    end
end
end
