require 'optparse'

module Veewee
  module Command
    class BaseboxList < Vagrant::Command::Base
      def execute
        options = {}

        opts = OptionParser.new do |opts|
          opts.banner = "Lists all defined baseboxes"
          opts.separator ""
          opts.separator "Usage: vagrant basebox list"
        end

        # Parse the options
        argv = parse_options(opts)
        return if !argv

        Veewee::Session.list_definitions
      end
    end
  end
end
