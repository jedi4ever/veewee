module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        def create(options={})

          guessed_port=guess_free_port(definition.ssh_host_port.to_i,definition.ssh_host_port.to_i+40).to_s
          if guessed_port.to_s!=definition.ssh_host_port
            env.ui.warn "Changing ssh port from #{definition.ssh_host_port} to #{guessed_port}"
            definition.ssh_host_port=guessed_port.to_s
          end


          # Suppress those annoying virtualbox messages
          self.suppress_messages

          self.create_vm

          # Attach ttyS0 to the VM for console output
          redirect_console=options[:redirectconsole]
          if redirect_console
            self.attach_serial_console
          end

          # Adds a folder to the vm for testing purposes
          self.add_shared_folder

          #Create a disk with the same name as the box_name
          self.create_disk

          self.add_ide_controller
          self.attach_isofile

          self.add_sata_controller
          self.attach_disk

          self.create_floppy
          self.add_floppy_controller
          self.attach_floppy

          self.add_ssh_nat_mapping

        end

      end
    end
  end
end
