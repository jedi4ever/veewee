require 'optparse'

module Veewee
  module Command
    module Vagrant
      class Templates < ::Vagrant::Command::Base
        def execute
          options = {}

          opts = OptionParser.new do |opts|
            opts.banner = "List the available templates"
            opts.separator ""
            opts.separator "Usage: vagrant basebox templates"
            opts.on("-d", "--debug", "enable debugging") do |d|
              options['debug'] = d
            end
          end

          # Parse the options
          argv = parse_options(opts)

          return if !argv

          begin
            venv=Veewee::Environment.new(options)
            venv.ui = @env.ui
            venv.ui.info("The following templates are available:",:prefix => false)
            venv.templates.each do |name,template|
              venv.ui.info("vagrant basebox define '<boxname>' '#{name}'",:prefix => false)
            end
          rescue Veewee::Error => ex
            venv.ui.error(ex,:prefix => false)
            exit -1
          end
        end
      end
    end
  end
end
