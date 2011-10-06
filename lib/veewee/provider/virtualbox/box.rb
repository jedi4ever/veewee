require 'veewee/provider/core/box'

require 'veewee/provider/virtualbox/box/create'
require 'veewee/provider/virtualbox/box/console_type'
require 'veewee/provider/virtualbox/box/destroy'

module Veewee
  module Provider
    module Virtualbox
      class Box < Veewee::Provider::Core::Box

        include ::Veewee::Provider::Virtualbox::BoxCommand

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
          env.logger.info("Vm exists? #{!vm.nil?}")
          return !vm.nil?
        end

        def running?
          return !raw.powered_off?
        end

        def create(options={})

          guessed_port=guess_free_port(definition.ssh_host_port.to_i,definition.ssh_host_port.to_i+40).to_s
          if guessed_port.to_s!=definition.ssh_host_port
            env.ui.warn "Changing ssh port from #{definition.ssh_host_port} to #{guessed_port}"
            definition.ssh_host_port=guessed_port.to_s
          end

          #Suppress those annoying virtualbox messages
          suppress_messages

          create_vm

          # Adds a folder to the vm for testing purposes
          add_shared_folder

          #Create a disk with the same name as the box_name
          create_disk

          add_ide_controller
          attach_isofile

          add_sata_controller
          attach_disk

          create_floppy
          add_floppy_controller
          attach_floppy

          add_ssh_nat_mapping

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

        def stop(options={})
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

        def halt(options={})
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

        def ssh_options

          ssh_options={
            :user => definition.ssh_user,
            :port => definition.ssh_host_port,
            :password => definition.ssh_password,
            :timeout => definition.ssh_login_timeout.to_i
          }
          return ssh_options

        end


      end # End Class
    end # End Module
  end # End Module
end # End Module
