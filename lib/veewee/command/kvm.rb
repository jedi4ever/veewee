module Veewee
  module Command
    class Kvm< Veewee::Command::GroupBase
      register "kvm", "Subcommand for kvm"

      desc "build [TEMPLATE_NAME] [BOX_NAME]", "Build box"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "overwrite the definition"
      def build(definition_name,box_name=nil)
        env.config.builders["kvm"].build(definition_name,box_name,options)
      end

    end

  end
end
