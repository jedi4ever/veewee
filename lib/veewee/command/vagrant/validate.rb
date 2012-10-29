require 'optparse'

module Veewee
  module Command
    module Vagrant
      class Validate < ::Vagrant::Command::Base
        def execute
          options = {
            'tags' => %w{vagrant puppet chef virtualbox}
          }

          opts = OptionParser.new do |opts|
            opts.banner = "Validates a box against vagrant compliancy rules"
            opts.separator ""
            opts.separator "Usage: vagrant basebox validate <boxname>"

            opts.on("-d", "--debug", "enable debugging") do |d|
              options['debug'] = d
            end

            opts.on("-t", "--tags vagrant,puppet,chef", Array, "tags to validate") do |t|
              options['tags'] = t
            end

          end

          # Parse the options
          argv = parse_options(opts)
          return if !argv
          raise ::Vagrant::Errors::CLIInvalidUsage, :help => opts.help.chomp if argv.length < 1

          begin
            venv=Veewee::Environment.new(options)
            venv.ui=@env.ui
            box_name=argv[0]
            venv.providers["virtualbox"].get_box(box_name).validate_vagrant(options)
          rescue Veewee::Error => ex
            venv.ui.error(ex,:prefix => false)
            exit -1
          end

        end
      end
    end
  end
end
