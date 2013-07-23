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
          env.logger.info ("Checking if the VM #{name} #{type} this can take a while because of how remote PowerShell works")
          case type
            when :exists
              result = powershell_exec ("Get-VM")
              status = (result.stdout.include? "#{name}") ? true : false
              env.logger.info("VM #{name} #{type}? #{status}")
            when :running
              env.logger.info("NOT YET IMPLEMENTED #{type} TESTING")
          end
          return status
        end
      end
    end
  end
end
