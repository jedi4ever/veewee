require 'optparse'

module Veewee
  module Command
    module Vagrant
      class Define < ::Vagrant::Command::Base
        def execute
          options = {}

          opts = OptionParser.new do |opts|
            opts.banner = "Define a new basebox based on a template"
            opts.separator ""
            opts.separator "Usage: vagrant basebox define <boxname> <template>"

            opts.on("-d", "--debug", "enable debugging") do |d|
              options['debug'] = d
            end

            opts.on("-f", "--force", "force overwrite") do |f|
              options['force'] = f
            end

          end

          # Parse the options
          argv = parse_options(opts)
          return if !argv
          raise ::Vagrant::Errors::CLIInvalidUsage, :help => opts.help.chomp if argv.length < 2

          begin
            venv=Veewee::Environment.new(options)
            venv.ui=@env.ui
            definition_name=argv[0]
            template_name=argv[1]
            venv.definitions.define(definition_name,template_name,options)
            venv.ui.info "The basebox '#{definition_name}' has been successfully created from the template '#{template_name}'"
            venv.ui.info "You can now edit the definition files stored in definitions/#{definition_name} or build the box with:"
            venv.ui.info "vagrant basebox build '#{definition_name}'"
          rescue Veewee::Error => ex
            venv.ui.error(ex,:prefix => false)
            exit -1
          end

        end
      end
    end
  end
end
