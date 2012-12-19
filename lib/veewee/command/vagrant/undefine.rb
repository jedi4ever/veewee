require 'optparse'

module Veewee
  module Command
    module Vagrant
      class Undefine < ::Vagrant::Command::Base
        def execute
          options = {}

          opts = OptionParser.new do |opts|
            opts.banner = "Remove the definition of a basebox"
            opts.separator ""
            opts.separator "Usage: vagrant basebox undefine <boxname>"

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
            definition_name=argv[0]
            venv.definitions.undefine(definition_name,options)
            venv.ui.info("Definition '#{definition_name}' successfully removed",:prefix => false)
          rescue Veewee::Error => ex
            venv.ui.error(ex,:prefix => false)
            exit -1
          end

        end
      end
    end
  end
end
