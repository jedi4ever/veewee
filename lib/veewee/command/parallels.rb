module Veewee
  module Command
    class Parallels< Veewee::Command::GroupBase

      register "parallels", "Subcommand for Parallels"

      desc "build [BOX_NAME]", "Build box"
      # TODO move common build options into array
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

      desc "validate [BOX_NAME]", "Validates a box against parallels compliancy rules"
      method_option :tags,:type => :array, :default => %w{parallels puppet chef}, :aliases => "-t", :desc => "tags to validate"
      def validate(box_name)
        venv=Veewee::Environment.new(options)
        venv.ui=env.ui
        venv.providers["parallels"].get_box(box_name).validate_parallels(options)
      end
    end
  end
end
