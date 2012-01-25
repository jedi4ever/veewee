module Veewee
  module Command
    class BaseboxExport < Vagrant::Command::Base
      def execute
        options = {}

        opts = OptionParser.new do |opts|
          opts.banner = "Exports the basebox to the vagrant box format"
          opts.separator ""
          opts.separator "Usage: vagrant basebox export <boxname>"
        end

        # Parse the options
        argv = parse_options(opts)
        return if !argv
        raise Vagrant::Errors::CLIInvalidUsage, :help => opts.help.chomp if argv.length < 1

        Veewee::Session.export_box(argv[0])
      end
    end
  end
end
