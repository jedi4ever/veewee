module Veewee
  module Command
    class Vbox< Veewee::Command::GroupBase

      register "vbox", "Subcommand for VirtualBox"

      desc "build [BOX_NAME]", "Build box"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "force the build"
      method_option :nogui,:type => :boolean , :default => false, :aliases => "-n", :desc => "no gui"
      method_option :auto,:type => :boolean , :default => false, :aliases => "-a", :desc => "auto answers"
      method_option :checksum , :type => :boolean , :default => false, :desc => "verify checksum"
      method_option :redirectconsole,:type => :boolean , :default => false, :aliases => "-r", :desc => "redirects console output"
      method_option :postinstall_include, :type => :array, :default => [], :aliases => "-i", :desc => "ruby regexp of postinstall filenames to additionally include"
      method_option :postinstall_exclude, :type => :array, :default => [], :aliases => "-e", :desc => "ruby regexp of postinstall filenames to exclude"
      def build(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["virtualbox"].get_box(box_name).build(options)
      end

      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "force the destroy"
      method_option :nogui,:type => :boolean , :default => false, :aliases => "-n", :desc => "no gui"
      desc "destroy [BOX_NAME]", "Destroys the basebox that was built"
      def destroy(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["virtualbox"].get_box(box_name).destroy(options)
      end

      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "force the shutdown"
      desc "halt [BOX_NAME]", "Activates a shutdown on the basebox"
      def halt(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["virtualbox"].get_box(box_name).halt(options)
      end

      method_option :nogui,:type => :boolean , :default => false, :aliases => "-n", :desc => "no gui"
      desc "up [BOX_NAME]", "Starts a Box"
      def up(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["virtualbox"].get_box(box_name).up(options)
      end

      desc "ssh [BOX_NAME] [COMMAND]", "Interactive ssh login"
      def ssh(box_name,command=nil)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["virtualbox"].get_box(box_name).issh(command)
      end


      desc "winrm [BOX_NAME] [COMMAND]", "Execute command via winrm"
      def winrm(box_name,command=nil)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["virtualbox"].get_box(box_name).winrm(command,{:exitcode => "*"})
      end

      desc "copy [BOX_NAME] [SRC] [DST]", "Copy a file to the VM"
      def copy(box_name,src,dst)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["virtualbox"].get_box(box_name).copy_to_box(src,dst)
      end

      desc "define [BOX_NAME] [TEMPLATE]", "Define a new basebox starting from a template"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "overwrite the definition"
      def define(definition_name, template_name)
        begin
          venv=Veewee::Environment.new(options)
          venv.ui=env.ui
          venv.definitions.define(definition_name,template_name,options)
          env.ui.info "The basebox '#{definition_name}' has been successfully created from the template '#{template_name}'"
          env.ui.info "You can now edit the definition files stored in definitions/#{definition_name} or build the box with:"
          env.ui.info "veewee vbox build '#{definition_name}'"
        rescue Error => ex
          env.ui.error("#{ex}",:prefix => false)
          exit -1
        end
      end

      desc "undefine [BOX_NAME]", "Removes the definition of a basebox "
      def undefine(definition_name)
        env.ui.info  "Removing definition #{definition_name}", :prefix => false
        begin
          venv=Veewee::Environment.new(options)
          venv.ui=env.ui
          venv.definitions.undefine(definition_name,options)
          env.ui.info "Definition #{definition_name} successfully removed" , :prefix => false
        rescue Error => ex
          env.ui.error("#{ex}",:prefix => false)
          exit -1
        end
      end

      desc "export [BOX_NAME]", "Exports the basebox to the vagrant format"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "overwrite existing file"
      def export(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["virtualbox"].get_box(box_name).export_vagrant(options)
      end

      desc "ostypes", "List the available Operating System types"
      def ostypes
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.ostypes.each do |name|
          env.ui.info "- #{name}"
        end
      end

      desc "validate [BOX_NAME]", "Validates a box against vagrant compliancy rules"
      method_option :tags, :type => :array , :default => %w{vagrant virtualbox puppet chef}, :aliases => "-t", :desc => "tags to validate"
      def validate(box_name)
        begin
          venv=Veewee::Environment.new(options)
          venv.ui = ::Veewee::UI::Shell.new(venv, shell)

          venv.providers["virtualbox"].get_box(box_name).validate_vagrant(options)
        rescue Veewee::Error => ex
          venv.ui.error(ex, :prefix => false)
          exit -1
        end
      end

      desc "screenshot [BOX_NAME] [PNGFILENAME]", "Takes a screenshot of the box"
      def screenshot(box_name,pngfilename)
        begin
          venv=Veewee::Environment.new(options)
          venv.ui = ::Veewee::UI::Shell.new(venv, shell)

          venv.providers["virtualbox"].get_box(box_name).screenshot(pngfilename,options)
        rescue Veewee::Error => ex
          venv.ui.error(ex, :prefix => false)
          exit -1
        end
      end

      # TODO pull up to GroupBase - since console_type is supported for every provider
      desc "sendkeys [BOX_NAME] [SEQUENCE]", "Sends the key sequence (comma separated) to the box. E.g for testing the :boot_cmd_sequence"
      def sendkeys(box_name, sequence)
        venv=Veewee::Environment.new(options)
        venv.ui = ::Veewee::UI::Shell.new(venv, shell)

        venv.providers["virtualbox"].get_box(box_name).console_type(sequence.split(","))
      end
    end

  end
end
