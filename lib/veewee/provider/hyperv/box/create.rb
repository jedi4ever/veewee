module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        def create(options={})

          if definition.hyperv_network_name
            # Create a virtual network switch
            self.add_network_switch
          else
            raise Veewee::Error,'No network hyperv_network_name specified'
          end

          # Attach ttyS0 to the VM for console output
          redirect_console=options[:redirectconsole]
          if redirect_console
            ui.warn 'Hyper-V does not support console redirection'
          end

          self.create_vm

          case definition.controller_kind.downcase
            when 'scsi'
              disk_device_number = 0
              isofile_ide_device_number = 0
              self.add_controller(definition.controller_kind)
            else
              disk_device_number = 0
              isofile_ide_device_number = 1
          end

          if definition.disk_count.to_i > 2
            self.attach_disk(definition.controller_kind,disk_device_number)
          end

          self.attach_isofile(isofile_ide_device_number,0,definition.iso_file)

          # On Windows we mount the Guest OS Additions, on all others we transfer the additions iso file to the guest
          # and mount it there.
          if definition.winrm_user && definition.winrm_password
            definition.skip_iso_transfer = 'true'

            self.attach_isofile(isofile_ide_device_number,1,'vmguest.iso')
          end

          unless definition.floppy_files.nil?
            self.create_floppy("virtualfloppy.vfd")
            self.attach_floppy
          end

          if definition.winrm_user && definition.winrm_password # prefer winrm
            env.ui.warn 'Using winrm because winrm_user and winrm_password are both set'
            #self.add_winrm_nat_mapping
          else
            #self.add_ssh_nat_mapping
          end

        end

        def cleanup(options={})
          self.detach_isofile(1,0)
          self.detach_isofile(1,1) if definition.skip_iso_transfer
          self.detach_floppy unless definition.floppy_files.nil?
        end

      end
    end
  end
end
