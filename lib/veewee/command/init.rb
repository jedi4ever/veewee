module Mccloud
  module Command
    class InitCommand < Base
      argument :box_name, :type => :string, :optional => false, :default => nil
      argument :template_name, :type => :string, :optional => false, :default => nil

      register "init NAME TEMPLATE-NAME", "Creates a new Mccloud project based on a template"

      def execute
        env.config.templates.each do |name,template|
           env.ui.info template.to_template if template.name==template_name
        end
      end

    end #Class
  end #Module
end #Module
