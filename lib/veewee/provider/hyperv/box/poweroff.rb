module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        def poweroff(options={})
          # If the vm is not powered off, perform a shutdown
          if self.running?
            env.ui.info "Forcefully shutting down VM [#{name}] on HyperV Host [#{definition.hyperv_host}]"
            #We force it here, maybe vm.shutdown is cleaner
            self.powershell_exec("Stop-VM -Name #{name} -Force")
          end
        end

      end
    end
  end
end
