module Veewee
  module Command
    class Vmfusion< Veewee::Command::GroupBase
      register "fusion", "Subcommand for fusion"

      desc "build [TEMPLATE_NAME] [BOX_NAME]", "Build box"
      method_option :force,:type => :boolean , :default => false, :aliases => "-f", :desc => "force the build"
      def build(definition_name,box_name=nil)
        env.config.builders["vmfusion"].build(definition_name,box_name,options)
      end

      desc "destroy [BOXNAME]", "Destroys the virtualmachine that was build"
      def destroy(box_name)
        env.config.builders["vmfusion"].get_box(box_name).destroy
      end    

      
    end

  end
end
