require 'veewee/builder/core/box'

require 'veewee/builder/virtualbox/helper/create'
require 'veewee/builder/virtualbox/helper/console_type'
require 'veewee/builder/virtualbox/helper/destroy'

module Veewee
  module Builder
    module Virtualbox
      class Box < Veewee::Builder::Core::Box
        
        include ::Veewee::Builder::Virtualbox::BoxHelper
        
        def initialize(name,env)

          require 'virtualbox'
          @vboxcmd=determine_vboxcmd
          super(name,env)
          
        end
                      
      def determine_vboxcmd
         return "VBoxManage"
      end   

      def exists?
        vm=VirtualBox::VM.find(name)
        env.logger.info ("Vm exists? #{!vm.nil?}")
        return !vm.nil?
      end
      
      def running?
        return 
      end
      
      def create(definition)
        
        #Suppress those annoying virtualbox messages
        suppress_messages
        
        create_vm(definition)
        
        # Adds a folder to the vm for testing purposes
        add_shared_folder(definition)

        #Create a disk with the same name as the box_name
        create_disk(definition)

        add_ide_controller(definition)
        attach_isofile(definition)
        
        add_sata_controller(definition)
        attach_disk(definition)
        
        create_floppy(definition)
        add_floppy_controller(definition)
        attach_floppy(definition)
        
        add_ssh_nat_mapping(definition)
        
      end
      
      def start(gui_enabled=true)
        # Once assembled we start the machine
        env.logger.info "Started the VM with GUI Enabled? #{gui_enabled}"
        if (gui_enabled)
          raw.start("gui")
        else
          raw.start("vrdp")
        end
      end
    
      def stop
        # If the vm is not powered off, perform a shutdown
        if (!raw.nil? && !(raw.powered_off?))
          env.ui.info "Shutting down vm #{name}"
          #We force it here, maybe vm.shutdown is cleaner
          begin
            raw.stop
            sleep 3
          rescue VirtualBox::Exceptions::InvalidVMStateException
            env.ui.error "There was problem sending the stop command because the machine is in an Invalid state"
            env.ui.error "Please verify leftovers from a previous build in your vm folder"
            exit -1
          end
        end
        
      end
      
      def halt
        if (!raw.nil? && !(raw.powered_off?))
          env.ui.info "Halting vm #{name}"
          #We force it here, maybe vm.shutdown is cleaner
          # VBoxManage controlvm  'lucid64' poweroff
          begin
            raw.halt
          rescue VirtualBox::Exceptions::InvalidVMStateException
            env.ui.error "There was problem sending the stop command because the machine is in an Invalid state"
            env.ui.error "Please verify leftovers from a previous build in your vm folder"
            exit -1
          end
          sleep 3
        end
      end

      # Get the IP address of the box
      def ip_address
        return "127.0.0.1"
      end


    end # End Class
end # End Module
end # End Module
end # End Module
