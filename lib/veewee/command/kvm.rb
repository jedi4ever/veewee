module Veewee
  module Command
    class Kvm< Veewee::Command::GroupBase

      register "kvm", "Subcommand for kvm"
      desc "build [BOX_NAME]", "Build box"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "force the build"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      method_option :nogui,:type => :boolean , :default => false, :aliases => "-n", :desc => "no gui"
      method_option :auto,:type => :boolean , :default => false, :aliases => "-a", :desc => "auto answers"
      method_option :postinstall_include, :type => :array, :default => [], :aliases => "-i", :desc => "ruby regexp of postinstall filenames to additionally include"
      method_option :postinstall_exclude, :type => :array, :default => [], :aliases => "-e", :desc => "ruby regexp of postinstall filenames to exclude"
      def build(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["kvm"].get_box(box_name).build(options)
      end

      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "force the destroy" 
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      method_option :nogui,:type => :boolean , :default => false, :aliases => "-n", :desc => "no gui"
      desc "destroy [BOXNAME]", "Destroys the virtualmachine that was build"
      def destroy(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["kvm"].get_box(box_name).destroy(options)
      end

      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "force the shutdown" 
      desc "halt [BOXNAME]", "Activates a shutdown the virtualmachine"
      def halt(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["kvm"].get_box(box_name).shutdown(options)
      end

      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      method_option :nogui,:type => :boolean , :default => false, :aliases => "-n", :desc => "no gui"
      desc "up [BOXNAME]", "Starts a Box"
      def up(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["kvm"].get_box(box_name).start(options)
      end

      desc "ssh [BOXNAME] [COMMAND]", "SSH to box"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def ssh(box_name,command=nil)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        puts venv.providers["kvm"].get_box(box_name).issh(command)
      end

      desc "define [BOXNAME] [TEMPLATE]", "Define a new basebox starting from a template"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "overwrite the definition"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def define(definition_name, template_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.definitions.define(definition_name,template_name,options)
        env.ui.info "The basebox '#{definition_name}' has been succesfully created from the template '#{template_name}'"
        env.ui.info "You can now edit the definition files stored in definitions/#{definition_name} or build the box with:"
        env.ui.info "veewee kvm build '#{definition_name}'"
      end

      desc "undefine [BOXNAME]", "Removes the definition of a basebox "
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def undefine(definition_name)
        env.ui.info "Removing definition #{definition_name}"
        begin
          venv=Veewee::Environment.new(options)
          venv.ui=env.ui
          venv.undefine(definition_name,options)
          venv.definitions.undefine(definition_name,options)
        rescue Error => ex
          env.ui.error "#{ex}"
          exit -1
        end
      end

      desc "validate [NAME]", "Validates a box against kvm compliancy rules"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def validate(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["kvm"].get_box(box_name).validate_kvm(options)
      end

      desc "ostypes", "List the available Operating System types"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def ostypes
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.ostypes.each do |name|
           env.ui.info "- #{name}"
        end
      end

      desc "templates", "List the currently available templates"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def templates
        env.ui.info "The following templates are available:"
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.templates.each do |name,template|
          env.ui.info "veewee kvm define '<box_name>' '#{name}'",:prefix => false
        end
      end

      desc "list", "Lists all defined boxes"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def list
        env.ui.info "The following local definitions are available:"
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.ui=env.ui
        venv.definitions.each do |name,definition|
          env.ui.info "- #{name}"
        end
      end
    end

  end
end
