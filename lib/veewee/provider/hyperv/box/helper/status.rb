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
              result = powershell_exec ("Get-VM|Select -Property VMName")
              status = (result.stdout.include? "#{name}") ? true : false
            when :running
              result = powershell_exec ("Get-VM|Select -Property VMName, State")
              #TODO: Fine tune the check running method
              status = (result.stdout.include? "#{name}") && result.stdout.include? "Running"? true : false
          end
          env.logger.info("VM #{name} #{type}? #{status}")
          return status
        end
      end
    end
  end
end
