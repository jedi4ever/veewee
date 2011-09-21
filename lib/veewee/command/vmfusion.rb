module Veewee
  module Command
    class Vmfusion< Veewee::Command::GroupBase

      register "fusion", "Subcommand for Vmware fusion"
      desc "build [TEMPLATE_NAME] [BOX_NAME]", "Build box"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "force the build"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging" 
      def build(definition_name,box_name=nil)
        venv=Veewee::Environment.new(options)
        
        venv.config.builders["vmfusion"].build(definition_name,box_name,options)
      end
      
      desc "destroy [BOXNAME]", "Destroys the virtualmachine that was build"
      def destroy(box_name)
        Veewee::Environment.new(options).config.builders["vmfusion"].get_box(box_name).destroy
      end   

      desc "define [BOXNAME] [TEMPLATE]", "Define a new basebox starting from a template"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "overwrite the definition" 
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging" 
      def define(definition_name, template_name)
        Veewee::Environment.new(options).define(definition_name,template_name,options)
        puts "The basebox '#{definition_name}' has been succesfully created from the template '#{template_name}'"
        puts "You can now edit the definition files stored in definitions/#{definition_name} or build the box with:"
        puts "veewee fusion build '#{definition_name}'"
      end

      desc "undefine [BOXNAME]", "Removes the definition of a basebox "
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging" 
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
   
      desc "export [NAME]", "Exports the basebox to the ova format" 
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging" 
      def export(box_name)
        venv=Veewee::Environment.new(options)
        venv.config.builders["vmfusion"].get_box(box_name).export_ova(options)
      end 
   
   
      desc "templates", "List the currently available templates"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging" 
      def templates
        env.ui.info "The following templates are available:"
        Veewee::Environment.new(options).get_template_paths.keys.each do |name|
          env.ui.info "veewee fusion define '<box_name>' '#{name}'"
        end        
      end

      desc "list", "Lists all defined boxes"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging" 
      def list
        env.ui.info "The following local definitions are available:"
        Veewee::Environment.new(options).get_definition_paths.keys.each do |name|
          env.ui.info "- #{name}"
        end
      end  

      
    end

  end
end
