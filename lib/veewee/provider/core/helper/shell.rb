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
          def shell_exec(command,options = {})
            result=ShellResult.new("","",-1)
            env.ui.info "Executing #{command}" unless options[:mute]
            escaped_command=command
            #        env.ui.info "#{escaped_command}"
            IO.popen("#{escaped_command}"+ " 2>&1") { |p|
              p.each_line{ |l|
                result.stdout+=l
                env.ui.info(l,{:new_line => false})  unless options[:mute]
              }
              result.status=Process.waitpid2(p.pid)[1].exitstatus
              if result.status!=0
                env.ui.error "Exit status was not 0 but #{result.status}" unless options[:mute]
              end
            }
            return result
          end


        end #Module
      end #Module
    end #Module
  end #Module
end #Module
