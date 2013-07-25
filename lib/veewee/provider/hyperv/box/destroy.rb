module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        def destroy(option={})
          env.logger.info "Destroying VM [#{name}] and removing all drives"
          self.powershell_exec "Get-VM #{name} ^| ^%{Stop-VM -VM $_ -Force ; Remove-VM -VM $_ -Force ; $p = $_.Path ; $v = $_.VMName ; Remove-Item -Recurse -Path $p\\$v}"#-Recurse -Force
        end

      end
    end
  end
end
