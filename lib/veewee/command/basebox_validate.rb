module Veewee
  module Command
    class BaseboxValidate < Vagrant::Command::Base
      def execute
        options = {}

        opts = OptionParser.new do |opts|
          opts.banner = "Validates a box against vagrant compliancy rules"
          opts.separator ""
          opts.separator "Usage: vagrant basebox validate <boxname>"

          opts.on("-u", "--user", "user to login with") do |u|
            options['user'] = u
          end
        end

        # Parse the options
        argv = parse_options(opts)
        return if !argv
        raise Vagrant::Errors::CLIInvalidUsage, :help => opts.help.chomp if argv.length < 1

        Veewee::Session.validate_box(argv[0], options)
      end
    end
  end
end
