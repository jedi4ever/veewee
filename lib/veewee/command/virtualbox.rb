module Veewee
  module Command
    class Virtualbox< Veewee::Command::GroupBase
      register "vbox", "Subcommand for Virtualbox"

      desc "build [TEMPLATE_NAME] [BOX_NAME]", "Build box"
      def build(definition_name,box_name=nil)
        env.config.builders["vbox"].build(definition_name,box_name,options)
      end

    end

  end
end
