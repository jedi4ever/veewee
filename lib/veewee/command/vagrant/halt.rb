require 'optparse'

module Veewee
  module Command
    module Vagrant
      class Halt < ::Vagrant::Command::Base
        def execute
          options = {}

          opts = OptionParser.new do |opts|
            opts.banner = "Shutdown the basebox"
            opts.separator ""
            opts.separator "Usage: vagrant basebox halt <boxname>"

            opts.on("-f", "--force", "overwrite the basebox") do |f|
              options['force'] = f
            end

            opts.on("-d", "--debug", "enable debugging") do |d|
              options['debug'] = d
            end

          end

          # Parse the options
          argv = parse_options(opts)
          return if !argv
          raise ::Vagrant::Errors::CLIInvalidUsage, :help => opts.help.chomp if argv.length < 1

          begin
            venv=Veewee::Environment.new(options)
            venv.ui=@env.ui
            venv.providers["virtualbox"].get_box(argv[0]).halt(options)
          rescue Veewee::Error => ex
            venv.ui.error(ex,:prefix => false)
            exit -1
          end

        end
      end
    end
  end
end
