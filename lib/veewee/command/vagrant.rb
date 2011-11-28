require 'veewee'

module Veewee
  module Vagrant
    class Command < ::Vagrant::Command::GroupBase

      register "basebox", "Commands to manage baseboxes"

      desc "build [BOX_NAME]", "Build box"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "force the build"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      method_option :nogui,:type => :boolean , :default => false, :aliases => "-n", :desc => "no gui"
      method_option :auto,:type => :boolean , :default => false, :aliases => "-a", :desc => "auto answers"
      method_option :redirectconsole,:type => :boolean , :default => false, :aliases => "-r", :desc => "redirects console output"
      method_option :postinstall_include, :type => :array, :default => [], :aliases => "-i", :desc => "ruby regexp of postinstall filenames to additionally include"
      method_option :postinstall_exclude, :type => :array, :default => [], :aliases => "-e", :desc => "ruby regexp of postinstall filenames to exclude"
      def build(box_name)
        begin
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["virtualbox"].get_box(box_name).build(options)
        rescue Veewee::Error => ex
          venv.ui.error ex
          exit -1
        end
      end

      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "force the destroy" 
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      method_option :nogui,:type => :boolean , :default => false, :aliases => "-n", :desc => "no gui"
      desc "destroy [BOXNAME]", "Destroys the basebox that was build"
      def destroy(box_name)
        begin
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["virtualbox"].get_box(box_name).destroy(options)
        rescue Veewee::Error => ex
          venv.ui.error ex
          exit -1
        end
      end

      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "force the shutdown" 
      desc "halt [BOXNAME]", "Activates a shutdown the basebox"
      def halt(box_name)
        begin
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["virtualbox"].get_box(box_name).shutdown(options)
        rescue Veewee::Error => ex
          venv.ui.error ex
          exit -1
        end
      end

      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      method_option :nogui,:type => :boolean , :default => false, :aliases => "-n", :desc => "no gui"
      desc "up [BOXNAME]", "Starts a Box"
      def up(box_name)
        begin
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["virtualbox"].get_box(box_name).start(options)
        rescue Veewee::Error => ex
          venv.ui.error ex
          exit -1
        end
      end

      desc "ssh [BOXNAME] [COMMAND]", "Shows SSH information"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def ssh(box_name,command=nil)
        begin
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        puts venv.providers["virtualbox"].get_box(box_name).issh(command)
        rescue Veewee::Error => ex
          venv.ui.error ex
          exit -1
        end
      end

      desc "define [BOXNAME] [TEMPLATE]", "Define a new basebox starting from a template"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "overwrite the definition"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def define(definition_name, template_name)
        begin
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.definitions.define(definition_name,template_name,options)
        env.ui.info "The basebox '#{definition_name}' has been succesfully created from the template '#{template_name}'"
        env.ui.info "You can now edit the definition files stored in definitions/#{definition_name} or build the box with:"
        env.ui.info "vagrant basebox build '#{definition_name}'"
        rescue Veewee::Error => ex
          venv.ui.error ex
          exit -1
        end
      end

      desc "undefine [BOXNAME]", "Removes the definition of a basebox "
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def undefine(definition_name)
        begin
        env.ui.info  "Removing definition #{definition_name}", :prefix => false
        begin
          venv=Veewee::Environment.new(options)
          venv.ui=env.ui
          venv.definitions.undefine(definition_name,options)
          env.ui.info "Definition #{definition_name} succesfully removed" , :prefix => false
        rescue Error => ex
          env.ui.error "#{ex}",:prefix => false
          exit -1
        end
        rescue Veewee::Error => ex
          venv.ui.error ex
          exit -1
        end
      end

      desc "ostypes", "List the available Operating System types"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def ostypes
        begin
        venv=Veewee::Environment.new(options)
        venv.ui = ::Veewee::UI::Shell.new(venv, shell)
        venv.ostypes.each do |name|
           env.ui.info "- #{name}"
        end
        rescue Veewee::Error => ex
          venv.ui.error ex
          exit -1
        end
      end

      desc "templates", "List the currently available templates"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def templates
        begin
        venv=Veewee::Environment.new(options)
        venv.ui = ::Veewee::UI::Shell.new(venv, shell)
        venv.ui.info "The following templates are available:"
        venv.templates.each do |name,template|
          env.ui.info "vagrant basebox define '<box_name>' '#{name}'",:prefix => false
        end
        rescue Veewee::Error => ex
          venv.ui.error ex
          exit -1
        end
      end

      desc "list", "Lists all defined boxes"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def list
        begin
        venv=Veewee::Environment.new(options)
        venv.ui = ::Veewee::UI::Shell.new(venv, shell)
        venv.ui.info "The following local definitions are available:"
        venv.definitions.each do |name,definition|
          env.ui.info "- #{name}"
        end
        rescue Veewee::Error => ex
          venv.ui.error ex
          exit -1
        end
      end

      desc "validate [NAME]", "Validates a box against vagrant compliancy rules"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      def validate(box_name)
        begin
        venv=Veewee::Environment.new(options)
        venv.ui = ::Veewee::UI::Shell.new(venv, shell)

        venv.providers["virtualbox"].get_box(box_name).validate_vagrant(options)
        rescue Veewee::Error => ex
          venv.ui.error ex
          exit -1
        end
      end

      desc "export [NAME]", "Exports the basebox to the vagrant box format"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "overwrite existing file"
      def export(box_name)
        begin
          venv=Veewee::Environment.new(options)
          venv.ui = ::Veewee::UI::Shell.new(venv, shell)
          venv.providers["virtualbox"].get_box(box_name).export_vagrant(options)
        rescue Veewee::Error => ex
          venv.ui.error ex
          exit -1
        end
      end

    end
  end
end
