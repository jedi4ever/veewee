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
          case type
            when :exists
              command = self.pscmd ("Get-VM -Name #{name}")
              shell_results = shell_exec("#{command}", {:mute => true, :status => 1})
              status = (shell_results.stdout.include? "unable to find") ? true : false
              env.logger.info("Vm #{type}? #{status}")
            when :running
              env.logger.info("NOT YET IMPLEMENTED")
          end
          return status
        end
      end
    end
  end
end
