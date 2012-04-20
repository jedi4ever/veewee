require 'optparse'

module Veewee
  module Command
    module Vagrant
      class Build < ::Vagrant::Command::Base
        def execute
          options = {}

          opts = OptionParser.new do |opts|
            opts.banner = "Build the box <boxname>"
            opts.separator ""
            opts.separator "Usage: vagrant basebox build <boxname>"

            opts.on("-f", "--force", "overwrite the basebox") do |f|
              options['force'] = f
            end

            opts.on("-n", "--nogui", "no gui") do |n|
              options['nogui'] = n
            end

            opts.on("-a", "--auto", "auto answers") do |a|
              options['auto'] = a
            end

            opts.on("-d", "--debug", "enable debugging") do |d|
              options['debug'] = d
            end

            opts.on("-r", "--redirect-console", "redirects serial console") do |r|
              options['redirectconsole'] = r
            end

            opts.on("-i", "--include",Array,"ruby regexp of postinstall filenames to additionally include") do |i|
              options['postinstall_include'] = i
            end

            opts.on("-e", "--exclude",Array,"ruby regexp of postinstall filenames to exclude") do |e|
              options['postinstall_list'] = e
            end

            opts.on("--[no-]md5","force to check iso file md5 sum") do |v|
              options['md5check'] = v
            end

          end

          # Parse the options
          argv = parse_options(opts)
          return if !argv
          raise ::Vagrant::Errors::CLIInvalidUsage, :help => opts.help.chomp if argv.length < 1

          begin
            venv=Veewee::Environment.new(options)
            venv.ui=@env.ui
            venv.providers["virtualbox"].get_box(argv[0]).build(options)
          rescue Veewee::Error => ex
            venv.ui.error(ex, :prefix => false)
            exit -1
          end

        end
      end
    end
  end
end
