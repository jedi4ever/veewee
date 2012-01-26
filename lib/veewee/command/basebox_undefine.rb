module Veewee
  module Command
    class BaseboxUndefine < Vagrant::Command::Base
      def execute
        options = {}

        opts = OptionParser.new do |opts|
          opts.banner = "Removes the definition of a basebox "
          opts.separator ""
          opts.separator "Usage: vagrant basebox undefine <boxname>"
        end

        # Parse the options
        argv = parse_options(opts)
        return if !argv
        raise Vagrant::Errors::CLIInvalidUsage, :help => opts.help.chomp if argv.length < 1

        Veewee::Session.undefine(argv[0])
      end
    end
  end
end
