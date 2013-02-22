

module Veewee
  module Command
    class Fusion< Veewee::Command::GroupBase

      register "fusion", "Subcommand for Vmware fusion"

      desc "build [BOX_NAME]", "Build box"
      # TODO move common build options into array
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "force the build"
      method_option :nogui,:type => :boolean , :default => false, :aliases => "-n", :desc => "no gui"
      method_option :auto,:type => :boolean , :default => false, :aliases => "-a", :desc => "auto answers"
      method_option :checksum , :type => :boolean , :default => false, :desc => "verify checksum"
      method_option :postinstall_include, :type => :array, :default => [], :aliases => "-i", :desc => "ruby regexp of postinstall filenames to additionally include"
      method_option :postinstall_exclude, :type => :array, :default => [], :aliases => "-e", :desc => "ruby regexp of postinstall filenames to exclude"
      def build(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["vmfusion"].get_box(box_name).build(options)
      end

      desc "validate [BOX_NAME]", "Validates a box against vmfusion compliancy rules"
      method_option :tags, :type => :array , :default => %w{vmfusion puppet chef}, :aliases => "-t", :desc => "tags to validate"
      def validate(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["vmfusion"].get_box(box_name).validate_vmfusion(options)
      end

      desc "export [BOX_NAME]", "Exports the basebox to the ova format"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "overwrite existing file"
      def export(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["vmfusion"].get_box(box_name).export_ova(options)
      end

      desc "add_share [BOX_NAME] [SHARE_NAME] [SHARE_PATH]", "Adds a share to the guest"
      def add_share(box_name, share_name, share_path)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
#          command="#{File.dirname().shellescape}/vmware-vdiskmanager -c -s #{definition.disk_size}M -a lsilogic -t #{disk_type} #{name}.vmdk"
#          shell_results=shell_exec("#{command}",{:mute => true})
        venv.providers["vmfusion"].get_box(box_name).add_share(share_name, share_path)

      end

    end

  end
end
