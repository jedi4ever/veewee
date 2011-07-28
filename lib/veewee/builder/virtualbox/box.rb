require 'veewee/util/shell'
require 'veewee/util/tcp'
require 'veewee/util/web'
require 'veewee/util/ssh'

require 'veewee/builder/core/box'

require 'veewee/builder/virtualbox/assemble'
require 'veewee/builder/virtualbox/build'
require 'veewee/builder/virtualbox/destroy'
require 'veewee/builder/virtualbox/export_vagrant'
require 'veewee/builder/virtualbox/validate_vagrant'

require 'veewee/builder/virtualbox/helper/ssh'
require 'veewee/builder/virtualbox/helper/console_type'
require 'veewee/builder/virtualbox/helper/snapshots'
require 'veewee/builder/virtualbox/helper/transaction'

module Veewee
  module Builder
    module Virtualbox
    class Box < Veewee::Builder::Core::Box
      include Veewee::Builder::Core
      include Veewee::Builder::Virtualbox
      
      def initialize(environment,box_name,definition_name,builder_options={})
        super(environment,box_name,definition_name,builder_options)
        @vboxcmd=determine_vboxcmd
      end    
     
      def set_definition(definition_name)
        @definition=@environment.get_definition(definition_name)
      end

       def determine_vboxcmd
         return "VBoxManage"
       end   

       def suppress_messages
         #Setting this annoying messages to register
         VirtualBox::ExtraData.global["GUI/RegistrationData"]="triesLeft=0"
         VirtualBox::ExtraData.global["GUI/UpdateDate"]="1 d, 2009-09-20"
         VirtualBox::ExtraData.global["GUI/SuppressMessages"]="confirmInputCapture,remindAboutAutoCapture,remindAboutMouseIntegrationOff"
         VirtualBox::ExtraData.global["GUI/UpdateCheckCount"]="60"
         update_date=Time.now+86400
         VirtualBox::ExtraData.global["GUI/UpdateDate"]="1 d, #{update_date.year}-#{update_date.month}-#{update_date.day}, stable"
         VirtualBox::ExtraData.global.save
       end

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

    end # End Class
end # End Module
end # End Module
end # End Module