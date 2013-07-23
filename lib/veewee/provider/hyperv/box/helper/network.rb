module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        def add_network_switch
          powershell_exec("New-VMSwitch -Name #{definition.hyperv_network_name} -NetAdapterName #{definition.hyperv_host_nic}")
        end

        def add_network_card
          powershell_exec("Add-VMNetworkAdapter -VMName #{name} -Name #{definition.hyperv_network_name} -DynamicMacAddress")
        end

        def add_ssh_nat_mapping
          unless definition.nil?
            unless definition.skip_nat_mapping == true
              #Map SSH Ports
              if self.running?
                command="#{@vboxcmd} controlvm \"#{name}\" natpf#{self.natinterface} \"guestssh,tcp,,#{definition.ssh_host_port},,#{definition.ssh_guest_port}\""
              else
                command="#{@vboxcmd} modifyvm \"#{name}\" --natpf#{self.natinterface} \"guestssh,tcp,,#{definition.ssh_host_port},,#{definition.ssh_guest_port}\""
              end
            shell_exec("#{command}")
          end
        end
        end

        def add_winrm_nat_mapping
          unless definition.nil?
            #Map WinRM Ports
            unless definition.skip_nat_mapping
              if self.running?
                command="#{@vboxcmd} controlvm \"#{name}\" natpf#{self.natinterface} \"guestwinrm,tcp,,#{definition.winrm_host_port},,#{definition.winrm_guest_port}\""
              else
                command="#{@vboxcmd} modifyvm \"#{name}\" --natpf#{self.natinterface} \"guestwinrm,tcp,,#{definition.winrm_host_port},,#{definition.winrm_guest_port}\""
              end
              shell_exec("#{command}")
            end
          end
        end

      end
    end
  end
end