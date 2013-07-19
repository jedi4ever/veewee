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
          shell_results = shell_exec("#{command}", {:mute => true, :status => 1})
          env.logger.info("Vm #{type}? #{shell_results}")
          return shell_results
        end

        #COMMANDS = { :running => "%s list runningvms", :exists => "%s list vms" }
      end
    end
  end
end
