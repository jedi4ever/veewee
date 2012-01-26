require 'optparse'

module Veewee
  module Command
    class BaseboxOstypes < Vagrant::Command::Base
      def execute
        options = {}

        opts = OptionParser.new do |opts|
          opts.banner = "List the available Operating System types"
          opts.separator ""
          opts.separator "Usage: vagrant basebox ostypes"
        end

        # Parse the options
        argv = parse_options(opts)
        return if !argv

        Veewee::Session.list_ostypes
      end
    end
  end
end
