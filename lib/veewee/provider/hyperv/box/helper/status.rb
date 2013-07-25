module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        def exists?
          check?(:exists)
        end

        def running?
          check?(:running)
        end

        private

        def check? type
          env.logger.info("Checking if the VM [#{name}] #{type}")
          case type
            when :exists
              result = powershell_exec("$obj = Get-VM ^| Select -Property VMName ; Foreach ($o in $obj) {if ($o.VMName -eq '#{name}') {'true' ; exit}} 'false'")
              status = (result.stdout.chomp == 'true') ? true: false
            when :running
              result = powershell_exec "Get-VM ^| Select -Property VMName, State"
              #TODO: Fine tune the check running method
              status = (result.stdout.include? "#{name}") && (result.stdout.include? "Running") ? true : false
            else
              env.logger.info("Unsupported check type #{type} specified")
              status = false
          end
          env.logger.info("VM #{name} #{type}? #{status}")
          status
        end
      end
    end
  end
end
