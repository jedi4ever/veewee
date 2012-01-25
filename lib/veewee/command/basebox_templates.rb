require 'optparse'

module Veewee
  module Command
    class BaseboxTemplates < Vagrant::Command::Base
      def execute
        options = {}

        opts = OptionParser.new do |opts|
          opts.banner = "List the currently available basebox templates"
          opts.separator ""
          opts.separator "Usage: vagrant basebox templates"
        end

        # Parse the options
        argv = parse_options(opts)
        return if !argv

        Veewee::Session.list_templates
      end
    end
  end
end
