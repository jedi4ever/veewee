module Veewee
  module Builder
    module Virtualbox
       def add_ssh_nat_mapping
         vm=VirtualBox::VM.find(@box_name)
         #Map SSH Ports
         #			command => "${vboxcmd} modifyvm '${vname}' --natpf1 'guestssh,tcp,,${hostsshport},,${guestsshport}'",
         port = VirtualBox::NATForwardedPort.new
         port.name = "guestssh"
         port.guestport = @definition.ssh_guest_port.to_i
         port.hostport = @definition.ssh_host_port.to_i
         vm.network_adapters[0].nat_driver.forwarded_ports << port
         port.save
         vm.save  
       end
     end
   end
 end
 