module Veewee
  module Command
    class Vmfusion< Veewee::Command::GroupBase
      register "fusion", "Subcommand for fusion"

      desc "build [TEMPLATE_NAME] [BOX_NAME]", "Build box"
      def build(definition_name,box_name=nil)
        env.config.builders["vmfusion"].build(definition_name,box_name,options)
      end

    end

  end
end
