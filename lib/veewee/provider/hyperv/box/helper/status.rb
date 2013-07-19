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
          #status = (shell_results.stdout.include? "unable to find") ? false : true
          status = shell_results.status ? 0 : 1
          env.logger.info("Vm #{type}? #{status.zero?}")
          return status.zero?
        end

      end
    end
  end
end
