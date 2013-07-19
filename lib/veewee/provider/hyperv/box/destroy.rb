module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        command = self.pscmd ("Remove-VM -Name #{name} -Force")
        shell_exec("#{command}", {:mute => true})

      end
    end
  end
end
