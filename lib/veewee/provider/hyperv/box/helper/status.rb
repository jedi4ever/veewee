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
          status = (shell_results.stdout.include? "unable to find") ? false : true
          env.logger.info("Vm #{type}? #{status}")
          return status
        end

        #COMMANDS = { :running => "%s list runningvms", :exists => "%s list vms" }
      end
    end
  end
end
