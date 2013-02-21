module Veewee
  module Command
    class Parallels< Veewee::Command::GroupBase
      class_option :debug,:type => :boolean , :default => false, :desc => "enable debugging"

      register "parallels", "Subcommand for Parallels"
      desc "build [BOX_NAME]", "Build box"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "force the build"
      method_option :auto,:type => :boolean , :default => false, :aliases => "-a", :desc => "auto answers"
      method_option :checksum , :type => :boolean , :default => false, :desc => "verify checksum"
      method_option :postinstall_include, :type => :array, :default => [], :aliases => "-i", :desc => "ruby regexp of postinstall filenames to additionally include"
      method_option :postinstall_exclude, :type => :array, :default => [], :aliases => "-e", :desc => "ruby regexp of postinstall filenames to exclude"
      def build(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["parallels"].get_box(box_name).build(options)
      end

      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "force the destroy" 
      desc "destroy [BOXNAME]", "Destroys the virtualmachine that was built"
      def destroy(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["parallels"].get_box(box_name).destroy(options)
      end

      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "force the shutdown"
      desc "halt [BOXNAME]", "Activates a shutdown the virtualmachine"
      def halt(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["parallels"].get_box(box_name).halt(options)
      end

      method_option :nogui,:type => :boolean , :default => false, :aliases => "-n", :desc => "no gui"
      desc "up [BOXNAME]", "Starts a Box"
      def up(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["parallels"].get_box(box_name).up(options)
      end

      desc "ssh [BOXNAME] [COMMAND]", "SSH to box"
      def ssh(box_name,command=nil)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["parallels"].get_box(box_name).issh(command)
      end

      desc "define [BOXNAME] [TEMPLATE]", "Define a new basebox starting from a template"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "overwrite the definition"
      def define(definition_name, template_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.definitions.define(definition_name,template_name,options)
        env.ui.info "The basebox '#{definition_name}' has been successfully created from the template '#{template_name}'"
        env.ui.info "You can now edit the definition files stored in definitions/#{definition_name} or build the box with:"
        env.ui.info "veewee parallels build '#{definition_name}'"
      end

      desc "undefine [BOXNAME]", "Removes the definition of a basebox "
      def undefine(definition_name)
        env.ui.info "Removing definition #{definition_name}" , :prefix => false
        begin
          venv=Veewee::Environment.new(options)
          venv.ui=env.ui
          venv.definitions.undefine(definition_name,options)
          env.ui.info "Definition #{definition_name} successfully removed",:prefix => false
        rescue Error => ex
          env.ui.error "#{ex}" , :prefix => false
          exit -1
        end
      end

      desc "validate [NAME]", "Validates a box against parallels compliancy rules"
      method_option :tags,:type => :array, :default => %w{parallels puppet chef}, :aliases => "-t", :desc => "tags to validate"
      def validate(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["parallels"].get_box(box_name).validate_parallels(options)
      end

      desc "ostypes", "List the available Operating System types"
      def ostypes
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.ostypes.each do |name|
           env.ui.info "- #{name}"
        end
      end

      desc "templates", "List the currently available templates"
      def templates
        env.ui.info "The following templates are available:",:prefix => false
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.templates.each do |name,template|
          env.ui.info "veewee parallels define '<box_name>' '#{name}'",:prefix => false
        end
      end

      desc "list", "Lists all defined boxes"
      def list
        env.ui.info "The following local definitions are available:",:prefix => false
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.definitions.each do |name,definition|
          env.ui.info "- #{name}"
        end
      end
    end
  end
end
