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
          shell_results = shell_exec("#{command}", {:mute => true, :donoterrorout => true})
          status = (shell_results.stdout.include? "unable to find") ? false : true
          env.logger.info("Vm #{type}? #{status}")
          return status
        end

      end
    end
  end
end
