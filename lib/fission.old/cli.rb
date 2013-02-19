module Fission
  class CLI
    def self.execute(args=ARGV)
      optparse = OptionParser.new do |opts|
        opts.banner = "\nUsage: fission [options] COMMAND [arguments]"

        opts.on_head('-v', '--version', 'Output the version of fission') do
          Fission.ui.output Fission::VERSION
          exit(0)
        end

        opts.on_head('-h', '--help', 'Displays this message') do
          show_all_help(optparse)
          exit(0)
        end

        opts.define_tail do
          commands_banner
        end

      end

      begin
        optparse.order! args
      rescue OptionParser::InvalidOption => e
        Fission.ui.output e
        show_all_help(optparse)
        exit(1)
      end

      if commands.include?(args.first)
        @cmd = Fission::Command.const_get(args.first.capitalize).new args.drop 1
      elsif is_snapshot_command?(args)
        klass = args.take(2).map {|c| c.capitalize}.join('')
        @cmd = Fission::Command.const_get(klass).new args.drop 2
      else
        show_all_help(optparse)
        exit(1)
      end

      begin
        @cmd.execute
      rescue Error => e
         puts "Error: #{e}"
      end
    end

    def self.commands
      cmds = Dir.entries(File.join(File.dirname(__FILE__), 'command')).select do |file|
        !File.directory? file
      end

      cmds.map { |cmd| File.basename(cmd, '.rb').gsub '_', ' ' }
    end

    private
    def self.is_snapshot_command?(args)
      args.first == 'snapshot' && args.count > 1 && commands.include?(args.take(2).join(' '))
    end

    def self.commands_banner
      text = "\nCommands:\n"
      Fission::Command.descendants.each do |command_klass|
        text << (command_klass.send :help)
      end

      text
    end

    def self.show_all_help(options)
      Fission.ui.output options
      Fission.ui.output commands_banner
    end

  end
end
