module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        def destroy(option={})

          self.powershell_exec("Remove-VM -Name #{name} -Force")

        end

      end
    end
  end
end
