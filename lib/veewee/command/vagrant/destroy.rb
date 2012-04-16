require 'optparse'

module Veewee
  module Command
    module Vagrant
      class Destroy < ::Vagrant::Command::Base
        def execute
          options = {}

          opts = OptionParser.new do |opts|
            opts.banner = "Destroy the basebox that was built"
            opts.separator ""
            opts.separator "Usage: vagrant basebox destroy <boxname>"

            opts.on("-f", "--force", "overwrite the basebox") do |f|
              options['force'] = f
            end

            opts.on("-n", "--nogui", "no gui") do |n|
              options['nogui'] = n
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
            venv.providers["virtualbox"].get_box(argv[0]).destroy(options)
          rescue Veewee::Error => ex
            venv.ui.error(ex,:prefix => false)
            exit -1
          end

        end
      end
    end
  end
end
