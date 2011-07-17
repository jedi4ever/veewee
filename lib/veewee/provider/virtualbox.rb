require 'veewee/provider/virtualbox/build'
require 'veewee/provider/virtualbox/destroy'
require 'veewee/provider/core/iso'
require 'virtualbox'

module Veewee
    class Virtualbox
      include Veewee::Provider::Core
      include Veewee::Provider::Virtualbox
      
      def initialize(boxname,definition,environment)
        @vboxcmd=determine_vboxcmd
        @definition=definition
        @boxname=boxname
        @environment=environment       
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
        vm=VirtualBox::VM.find(@boxname)
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

      def self.list_ostypes
        puts
        puts "Available os types:"
        VirtualBox::Global.global.lib.virtualbox.guest_os_types.collect { |os|
          puts "#{os.id}: #{os.description}"
        }      
      end
      
    end
end