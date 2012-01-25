module Veewee
  module Command
    class BaseboxDestroy < Vagrant::Command::Base
      def execute
        options = {}

        opts = OptionParser.new do |opts|
          opts.banner = "Destroys the virtualmachine that was build for a basebox"
          opts.separator ""
          opts.separator "Usage: vagrant basebox destroy <boxname>"
        end

        # Parse the options
        argv = parse_options(opts)
        return if !argv
        raise Vagrant::Errors::CLIInvalidUsage, :help => opts.help.chomp if argv.length < 1

        Veewee::Session.destroy_vm(argv[0])
      end
    end
  end
end
