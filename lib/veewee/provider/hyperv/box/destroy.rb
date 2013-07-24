module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        def destroy(option={})

          self.powershell_exec("Remove-VM -Name #{name} -Force")
          #self.powershell_exec("Get-VM #{name} | %{ Stop-VM -VM $_ -Force; Remove-VM -vm $_ -Force ; Remove-Item -Path $_.Path -Recurse -Force}")

        end

      end
    end
  end
end
