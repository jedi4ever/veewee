require 'optparse'

module Veewee
  module Command
    module Vagrant
      class Export < ::Vagrant::Command::Base
        def execute
          options = {}
          options['include'] = []
          options['vagrantfile'] = []

          opts = OptionParser.new do |opts|
            opts.banner = "Exports basebox to the vagrant box format"
            opts.separator ""
            opts.separator "Usage: vagrant basebox export <boxname>"

            opts.on("-d", "--debug", "enable debugging") do |d|
              options['debug'] = d
            end

            opts.on("-f", "--force", "force overwrite") do |f|
              options['force'] = f
            end

            opts.on( "--vagrantfile [FILE]", "vagrantfile") do |f|
              options['vagrantfile'] = f
            end

            opts.on("-i", "--include [FILE]", "include") do |f|
                options['include'] << f
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
            venv.providers["virtualbox"].get_box(box_name).export_vagrant(options)
          rescue Veewee::Error => ex
            venv.ui.error(ex,:prefix => false)
            exit -1
          end

        end
      end
    end
  end
end
