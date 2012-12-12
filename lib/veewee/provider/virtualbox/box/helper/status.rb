module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        def exists?
          return check?(:exists)
        end

        def running?
          return check?(:running)
        end

        private

        def check? type
          command = COMMANDS[type] % @vboxcmd
          shell_results=shell_exec("#{command}",{:mute => true})
          status=shell_results.stdout.split(/\n/).grep(/\"#{Regexp.escape(name)}\"/).size!=0

          env.logger.info("Vm #{type}? #{status}")
          return status
        end

        COMMANDS = { :running => "%s list runningvms", :exists => "%s list vms" }
      end
    end
  end
end
