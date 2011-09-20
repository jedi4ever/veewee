module Veewee
  module Command
    class Virtualbox< Veewee::Command::GroupBase
      register "vbox", "Subcommand for Virtualbox"

      desc "build [TEMPLATE_NAME] [BOX_NAME]", "Build box"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "force the build"
      def build(definition_name,box_name=nil)
        env.config.builders["virtualbox"].build(definition_name,box_name,options)
      end
      
      desc "destroy [BOXNAME]", "Destroys the virtualmachine that was build"
      def destroy(box_name)
        env.config.builders["virtualbox"].get_box(box_name).destroy
      end   

      desc "define [BOXNAME] [TEMPLATE]", "Define a new basebox starting from a template"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "overwrite the definition" 
      def define(definition_name, template_name)
        Veewee::Environment.new(options).define(definition_name,template_name,options)
        puts "The basebox '#{definition_name}' has been succesfully created from the template '#{template_name}'"
        puts "You can now edit the definition files stored in definitions/#{definition_name} or build the box with:"
        puts "veewee vbox build '#{definition_name}'"
      end

      desc "undefine [BOXNAME]", "Removes the definition of a basebox "
      def undefine(definition_name)
        puts "Removing definition #{definition_name}"
        begin
          Veewee::Environment.new(options).undefine(definition_name,options)
          puts "Definition #{definition_name} succesfully removed"
        rescue Error => ex
          puts "#{ex}"
          exit -1
        end
      end
      
   
      desc "templates", "List the currently available templates"
      def templates
        env.ui.info "The following templates are available:"
        Veewee::Environment.new(options).get_template_paths.keys.each do |name|
          env.ui.info "veewee vbox define '<box_name>' '#{name}'"
        end        
      end

      desc "list", "Lists all defined boxes"
      def list
        env.ui.info "The following local definitions are available:"
        Veewee::Environment.new(options).get_definition_paths.keys.each do |name|
          env.ui.info "- #{name}"
        end
      end
            
    end

  end
end