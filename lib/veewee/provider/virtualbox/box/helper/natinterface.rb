module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        def natinterface
          command="#{@vboxcmd} showvminfo --details --machinereadable \"#{self.name}\""
          shell_results=shell_exec("#{command}")

          if nats.length > 0 then nats[0].split('=')[0][-1,1] end
        end

      end
    end
  end
end
