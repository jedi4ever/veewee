module Veewee
  module Command
    class Vbox < Veewee::Command::GroupBase

      register :command => "vbox",
               :description => "Subcommand for VirtualBox",
               :provider => "virtualbox"

      desc "build [BOX_NAME]", "Build box"
      # TODO move common build options into array
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "force the build"
      method_option :nogui,:type => :boolean , :default => false, :aliases => "-n", :desc => "no gui"
      method_option :auto,:type => :boolean , :default => false, :aliases => "-a", :desc => "auto answers"
      method_option :checksum , :type => :boolean , :default => false, :desc => "verify checksum"
      method_option :redirectconsole,:type => :boolean , :default => false, :aliases => "-r", :desc => "redirects console output"
      method_option :postinstall_include, :type => :array, :default => [], :aliases => "-i", :desc => "ruby regexp of postinstall filenames to additionally include"
      method_option :postinstall_exclude, :type => :array, :default => [], :aliases => "-e", :desc => "ruby regexp of postinstall filenames to exclude"
      method_option :skip_to_postinstall, :aliases => ['--skip-to-postinstall'],  :type => :boolean,
                    :default => false,
                    :desc => "Skip to postinstall."
      def build(box_name)
        env.get_box(box_name).build(options)
      end

      desc "export [BOX_NAME]", "Exports the basebox to the vagrant format"
      method_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "overwrite existing file"
      method_option :vagrantfile,:type => :string , :default => "", :desc => "specify Vagrantfile"
      def export(box_name)
       env.get_box(box_name).export_vagrant(options)
      end

      desc "validate [BOX_NAME]", "Validates a box against vagrant compliancy rules"
      method_option :tags, :type => :array , :default => %w{vagrant virtualbox puppet chef}, :aliases => "-t", :desc => "tags to validate"
      def validate(box_name)
        begin
          venv=Veewee::Environment.new(options)
          venv.ui = ::Veewee::UI::Shell.new(venv, shell)
          venv.providers[@provider].get_box(box_name).validate_vagrant(options)
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

          venv.providers[@provider].get_box(box_name).screenshot(pngfilename,options)
        rescue Veewee::Error => ex
          venv.ui.error(ex, :prefix => false)
          exit -1
        end
      end
    end
  end
end
