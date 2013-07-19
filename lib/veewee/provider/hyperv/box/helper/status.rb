module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        def exists?
          return check?(:exists)
        end

        def running?
          return check?(:running)
        end

        private

        def check? type
          #command=

          command = self.pscmd ("Get-VM -Name #{name}")
          shell_results = shell_exec("#{command}", {:mute => true})
          if shell_results.status == 0
            env.logger.info("Vm #{type}? true")
            return true
          else
            env.logger.info("Vm #{type}? false")
            return false
          end

        end

        #COMMANDS = { :running => "%s list runningvms", :exists => "%s list vms" }
      end
    end
  end
end
