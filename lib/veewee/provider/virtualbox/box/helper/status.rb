module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        def exists?
          command="#{@vboxcmd} list vms"
          shell_results=shell_exec("#{command}",{:mute => true})
          exists=shell_results.stdout.split(/\n/).grep(/\"#{name}\"/).size!=0

          env.logger.info("Vm exists? #{exists}")
          return exists
        end

        def running?
          command="#{@vboxcmd} list runningvms"
          shell_results=shell_exec("#{command}",{:mute => true})
          running=shell_results.stdout.split(/\n/).grep(/\"#{name}\"/).size!=0

          env.logger.info("Vm running? #{running}")
          return running
        end

      end
    end
  end
end
