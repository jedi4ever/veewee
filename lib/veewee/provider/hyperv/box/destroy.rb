module Veewee
  module Provider
    module Hyperv
      module BoxCommand
        command = pscmd ("Remove-VM #{name}")
        shell_exec("#{command}")#,{:mute => true})
      end
    end
  end
end
