module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        def destroy(option={})

          command = self.pscmd ("Remove-VM -Name #{name} -Force")
          shell_exec("#{command}", {:mute => true})

        end

      end
    end
  end
end
