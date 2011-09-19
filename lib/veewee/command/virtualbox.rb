module Veewee
  module Command
    class Virtualbox< Veewee::Command::GroupBase
      register "vbox", "Subcommand for Virtualbox"

      desc "build [TEMPLATE_NAME] [BOX_NAME]", "Build box"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "overwrite the definition"
      def build(definition_name,box_name=nil)
        env.config.builders["virtualbox"].build(definition_name,box_name,options)
      end

    end

  end
end