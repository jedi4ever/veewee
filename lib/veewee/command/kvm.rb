module Veewee
  module Command
    class Kvm< Veewee::Command::GroupBase

      register "kvm", "Subcommand for kvm"
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
        venv.config.builders["kvm"].build(definition_name,box_name,options)
      end

      desc "destroy [BOXNAME]", "Destroys the virtualmachine that was build"
      def destroy(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.config.builders["kvm"].get_box(box_name).destroy
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
        env.ui.info "veewee vbox build '#{definition_name}'"
      end

      desc "undefine [BOXNAME]", "Removes the definition of a basebox "
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def undefine(definition_name)
        env.ui.info "Removing definition #{definition_name}"
        begin
          venv=Veewee::Environment.new(options)
          venv.ui=env.ui
          venv.undefine(definition_name,options)
          venv.info "Definition #{definition_name} succesfully removed"
        rescue Error => ex
          env.ui.error "#{ex}"
          exit -1
        end
      end

      desc "ostypes", "List the available Operating System types"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def ostypes
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.list_ostypes
      end

      desc "templates", "List the currently available templates"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def templates
        env.ui.info "The following templates are available:"
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.get_template_paths.keys.each do |name|
          env.ui.info "veewee vbox define '<box_name>' '#{name}'"
        end
      end

      desc "list", "Lists all defined boxes"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def list
        env.ui.info "The following local definitions are available:"
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.get_definition_paths.keys.each do |name|
          env.ui.info "- #{name}"
        end
      end
    end

  end
end
