module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        def create(options={})

          # First check if the directory where we create the VM is empty
          # Sometimes there are leftovers from badly terminated vms
          box_directory=File.join(self.get_vbox_home,name)
          if File.exists?(box_directory)
            raise Veewee::Error,"To create the vm '#{name}' the directory '#{box_directory}' needs to be empty. \nThis could be caused by an badly closed vm.\nRemove it manually before you proceed."
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

          use_sata = definition.use_sata
          if use_sata
            disk_device_number = 0
            isofile_ide_device_number = 0
          else
            disk_device_number = 0
            isofile_ide_device_number = 1
          end

          self.add_ide_controller
          if use_sata
            self.add_sata_controller
            self.attach_disk_sata(disk_device_number)
          else
            self.attach_disk_ide(disk_device_number)
          end
          self.attach_isofile(isofile_ide_device_number)
          self.attach_guest_additions

          self.create_floppy("virtualfloppy.vfd")

          self.add_floppy_controller
          self.attach_floppy

          if definition.winrm_user && definition.winrm_password # prefer winrm 
            env.ui.warn "Using winrm because winrm_user and winrm_password are both set"
            guessed_port=guess_free_port(definition.winrm_host_port.to_i,definition.winrm_host_port.to_i+40).to_s
            if guessed_port.to_s!=definition.winrm_host_port
              env.ui.warn "Changing winrm port from #{definition.winrm_host_port} to #{guessed_port}"
              definition.winrm_host_port=guessed_port.to_s
            end
            self.add_winrm_nat_mapping
          else
            guessed_port=guess_free_ssh_port(definition.ssh_host_port.to_i,definition.ssh_host_port.to_i+40).to_s
            if guessed_port.to_s!=definition.ssh_host_port
              env.ui.warn "Changing ssh port from #{definition.ssh_host_port} to #{guessed_port}"
              definition.ssh_host_port=guessed_port.to_s
            end
            self.add_ssh_nat_mapping
          end

        end

      end
    end
  end
end
