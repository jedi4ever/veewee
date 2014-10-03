module Veewee
  module Provider
    module Core
      module Helper

        class ShellResult
          attr_accessor :stdout
          attr_accessor :stderr
          attr_accessor :status

          def initialize(stdout,stderr,status)
            @stdout=stdout
            @stderr=stderr
            @status=status
          end
        end

        module Shell

          # http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/185404
          # This should work on windows too now
          # This will result in a ShellResult structure with stdout, stderr and status
          def shell_exec(command, options = {})
            defaults = { :mute => true, :status => 0, :stderr => "&1" }
            options  = defaults.merge(options)
            result   = ShellResult.new("","",-1)
            ui.info "Executing #{command}" unless options[:mute]
            env.logger.debug "Command: \"#{command}\""
            env.logger.debug "Output:"
            env.logger.debug "-------"
            escaped_command = command
            stderr_redirect = options[:stderr]? options[:stderr] : "&1"
            io_options = {}
            io_options[:external_encoding] = options[:external_encoding] if options[:external_encoding]

            IO.popen("#{escaped_command}"+ " 2>#{stderr_redirect}", io_options) do |pipe|
              pipe.each_line do |line|
                result.stdout += line
                ui.info(line, :new_line => false)  unless options[:mute]
                env.logger.debug(line.chomp)
              end
              result.status = Process.waitpid2(pipe.pid)[1].exitstatus
              if
                result.status.to_i != options[:status]
              then
                ui.error "Error: We executed a shell command and the exit status was not #{options[:status]}"
                ui.error "- Command :#{command}."
                ui.error "- Exitcode :#{result.status}."
                ui.error "- Output   :\n#{result.stdout}"
                raise Veewee::Error,"Wrong exit code for command #{command}"
              end
            end
            return result
          end


        end #Module
      end #Module
    end #Module
  end #Module
end #Module
