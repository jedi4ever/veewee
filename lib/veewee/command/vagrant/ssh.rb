require 'optparse'

module Veewee
  module Command
    module Vagrant
      class Ssh < ::Vagrant::Command::Base
        def execute
          options = {}

          opts = OptionParser.new do |opts|
            opts.banner = "Ssh into the basebox"
            opts.separator ""
            opts.separator "Usage: vagrant basebox ssh <boxname> <command>"

            opts.on("-d", "--debug", "enable debugging") do |d|
              options['debug'] = d
            end

          end

          # Parse the options
          argv = parse_options(opts)
          return if !argv

          begin
            venv=Veewee::Environment.new(options)
            venv.ui=@env.ui
            venv.providers["virtualbox"].get_box(argv[0]).issh(argv[1])
          rescue Veewee::Error => ex
            venv.ui.error(ex,:prefix => false)
            exit -1
          end

        end
      end
    end
  end
end
