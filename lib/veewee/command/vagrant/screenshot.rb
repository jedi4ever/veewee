require 'optparse'

module Veewee
  module Command
    module Vagrant
      class Screenshot < ::Vagrant::Command::Base
        def execute
          options = {}

          opts = OptionParser.new do |opts|
            opts.banner = "Grab a screenshot of a running basebox"
            opts.separator ""
            opts.separator "Usage: vagrant basebox screenshot <boxname> <pngfile>"

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
            box_name=argv[0]
            pngfilename=argv[1]
            venv.providers["virtualbox"].get_box(box_name).screenshot(pngfilename)
          rescue Veewee::Error => ex
            venv.ui.error(ex,:prefix => false)
            exit -1
          end

        end
      end
    end
  end
end
