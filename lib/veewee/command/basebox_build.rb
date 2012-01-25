require 'optparse'

module Veewee
  module Command
    class BaseboxBuild < Vagrant::Command::Base
      def execute
        options = {}

        opts = OptionParser.new do |opts|
          opts.banner = "Build the box <boxname>"
          opts.separator ""
          opts.separator "Usage: vagrant basebox build <boxname>"

          opts.on("-f", "--force", "overwrite the basebox") do |f|
            options['force'] = f
          end

          opts.on("-n", "--nogui", "no gui") do |n|
            options['nogui'] = n
          end
        end

        # Parse the options
        argv = parse_options(opts)
        return if !argv
        raise Vagrant::Errors::CLIInvalidUsage, :help => opts.help.chomp if argv.length < 1

        Veewee::Session.build(argv[0], options)
      end
    end
  end
end
