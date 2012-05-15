module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        def natinterface
          command="#{@vboxcmd} showvminfo --details --machinereadable \"#{self.name}\""
          shell_results=shell_exec("#{command}")

          nic_id=shell_results.stdout.split(/\n/).grep(/^nic/).grep(/nat/)[0].split('=')[0][-1,1]
          return nic_id
        end

      end
    end
  end
end
