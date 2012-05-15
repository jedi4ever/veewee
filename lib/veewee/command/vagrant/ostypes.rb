require 'optparse'

module Veewee
  module Command
    module Vagrant
      class Ostypes < ::Vagrant::Command::Base
        def execute
          options = {}

          opts = OptionParser.new do |opts|
            opts.banner = "List the available Operating System types"
            opts.separator ""
            opts.separator "Usage: vagrant basebox ostypes"
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
            venv.ostypes.each do |name|
              venv.ui.info("- #{name}", :prefix => false)
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
