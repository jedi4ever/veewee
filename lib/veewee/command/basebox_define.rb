require 'optparse'

module Veewee
  module Command
    class BaseboxDefine < Vagrant::Command::Base
      def execute
        options = {}

        opts = OptionParser.new do |opts|
          opts.banner = "Define a new basebox starting from a template"
          opts.separator ""
          opts.separator "Usage: vagrant basebox define <boxname> <template>"

          opts.on("-f", "--force", "overwrite the definition") do |f|
            options['force'] = f
          end
        end

        # Parse the options
        argv = parse_options(opts)
        return if !argv
        raise Vagrant::Errors::CLIInvalidUsage, :help => opts.help.chomp if argv.length < 2

        Veewee::Session.define(argv[0], argv[1], options)
      end
    end
  end
end
