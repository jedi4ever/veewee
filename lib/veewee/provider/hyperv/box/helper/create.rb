module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        def add_network_switch
          powershell_exec ("New-VMSwitch -Name #{definition.hyperv_network_name} -NetAdapterName #{definition.hyperv_host_nic}")
        end

        def add_network_card
          powershell_exec ("Add-VMNetworkAdapter -VMName #{name} -Name #{definition.hyperv_network_name} -DynamicMacAddress")
        end

        #TODO: def add_ssh_nat_mapping
          #unless definition.nil?
          #  unless definition.skip_nat_mapping == true
          #    #Map SSH Ports
          #    if self.running?
          #      command="#{@vboxcmd} controlvm \"#{name}\" natpf#{self.natinterface} \"guestssh,tcp,,#{definition.ssh_host_port},,#{definition.ssh_guest_port}\""
          #    else
          #      command="#{@vboxcmd} modifyvm \"#{name}\" --natpf#{self.natinterface} \"guestssh,tcp,,#{definition.ssh_host_port},,#{definition.ssh_guest_port}\""
          #    end
          #    shell_exec("#{command}")
          #  end
          #end
        #end

        def add_winrm_nat_mapping
          unless definition.nil?
            #Map WinRM Ports
            unless definition.skip_nat_mapping == true
              if self.running?
                command="#{@vboxcmd} controlvm \"#{name}\" natpf#{self.natinterface} \"guestwinrm,tcp,,#{definition.winrm_host_port},,#{definition.winrm_guest_port}\""
              else
                command="#{@vboxcmd} modifyvm \"#{name}\" --natpf#{self.natinterface} \"guestwinrm,tcp,,#{definition.winrm_host_port},,#{definition.winrm_guest_port}\""
              end
              shell_exec("#{command}")
            end
          end
        end

        #TODO: def add_shared_folder
        #  command="#{@vboxcmd} sharedfolder add  \"#{name}\" --name \"veewee-validation\" --hostpath \"#{File.expand_path(env.validation_dir)}\" --automount"
        #  shell_exec("#{command}")
        #end

        def add_controller (controller_kind = 'scsi')
          case controller_kind
            when 'scsi'
              powershell_exec ("Add-VMScsiController -VMName #{name}")
            else
              env.logger.warn("Hyper-V currently only supports (up to 12) additional SCSI controllers on top of the 2 default IDE controllers")
          end
        end

        def create_disk
          1.upto(definition.disk_count.to_i) do |f|
            ui.info "Creating new harddrive of size #{definition.disk_size.to_i}MB, format #{definition.disk_format}, variant #{definition.disk_variant} "
            command ="#{@vboxcmd} createhd --filename \"#{File.join(place,name,name+"#{f}."+definition.disk_format.downcase)}\" --size \"#{definition.disk_size.to_i}\" --format #{definition.disk_format.downcase} --variant #{definition.disk_variant.downcase}"
            shell_exec("#{command}")
          end
        end

        def attach_disk(controller_kind, device_number)
          1.upto(definition.disk_count.to_i) do |f|
            powershell_exec ("Add-VMHardDiskDrive -VMName #{name} -ControllerNumber #{device_number} -ControllerLocation #{f-1} ")
          end
        end

        def attach_isofile(device_number = 0, port = 0, iso_file = definition.iso_file)
          local_iso_file = File.join(env.config.veewee.iso_dir, iso_file)
          remote_iso_file = File.join("\\\\", definition.hyperv_host, "veewee", iso_file )
          powershell_exec ("Copy-Item -Path '#{local_iso_file}' -Destination '#{remote_iso_file}'", {:remote => false})
          ui.info "Mounting cdrom: #{remote_iso_file}"
          #command ="#{@vboxcmd} storageattach \"#{name}\" --storagectl \"IDE Controller\" --type dvddrive --port #{port} --device #{device_number} --medium \"#{full_iso_file}\""
          powershell_exec ("Set-VMDvdDrive -VMName #{name} -Path '#{remote_iso_file}'")
        end

        def detach_isofile(device_number = 0, port = 0)
          full_iso_file=File.join(env.config.veewee.iso_dir, definition.iso_file)
          ui.info "Un-Mounting cdrom: #{full_iso_file}"
          command ="#{@vboxcmd} storageattach \"#{name}\" --storagectl \"IDE Controller\" --type dvddrive --port #{port} --device #{device_number} --medium emptydrive"
          shell_exec("#{command}")
        end

        def detach_guest_additions(device_number = 0, port = 1)
          full_iso_file=File.join(env.config.veewee.iso_dir,"VBoxGuestAdditions_#{self.vboxga_version}.iso")
          ui.info "Un-Mounting guest additions: #{full_iso_file}"
          command ="#{@vboxcmd} storageattach \"#{name}\" --storagectl \"IDE Controller\" --type dvddrive --port #{port} --device #{device_number} --medium emptydrive"
          shell_exec("#{command}")
        end

        def attach_floppy
          # Attach floppy to machine (the vfd extension is crucial to detect msdos type floppy)
          unless definition.floppy_files.nil?
            local_floppy_file = File.join(definition.path, "virtualfloppy.vfd")
            remote_floppy_file = File.join("\\\\", definition.hyperv_host, "veewee", "virtualfloppy.vfd")
            powershell_exec ("Copy-Item -Path '#{local_floppy_file}' -Destination '#{remote_floppy_file}'", {:remote => false})
            ui.info "Mounting floppy: #{remote_floppy_file}"
            powershell_exec ("Set-VMFloppyDiskDrive -VMName #{name} -Path '#{remote_floppy_file}'")
          end
        end

        def detach_floppy
          # Detach floppy to machine (the vfd extension is crucial to detect msdos type floppy)
          unless definition.floppy_files.nil?
            floppy_file=File.join(definition.path,"virtualfloppy.vfd")
            ui.info "Un-Mounting floppy: #{floppy_file}"
            powershell_exec ("Set-VMFloppyDiskDrive -VMName #{name} -Path")
          end
        end

        def hyperv_os_type_id(veewee_type_id)
          type=env.ostypes[veewee_type_id][:hyperv]
          env.logger.info("Using HyperV os_type_id #{type}")
          return type
        end

        def create_vm
          if (definition.memory_size.to_i < 512)
            ui.warn "HyperV requires a minimum of 512MB RAM for a Guest OS, changing up from #{definition.memory_size}MB"
            definition.memory_size = "512"
          end

          env.logger.info "Creating VM #{name} : #{definition.memory_size}MB - #{definition.cpu_count} CPU - #{hyperv_os_type_id(definition.os_type_id)}"

          # Create a new named VM instance on the HyperV server
          powershell_exec ("New-VM -Name #{name} -NewVHDSizeBytes #{definition.disk_size}MB -NewVHDPath '#{File.join(definition.hyperv_store_path,name,name)}-0.vhdx' -SwitchName #{definition.hyperv_network_name}")

          if (definition.memory_size.to_i > 512) || (definition.cpu_count.to_i > 2) || (definition.hyperv_dynamic_memory) then
            dynmem = definition.hyperv_dynamic_memory ? "-DynamicMemory" : ""
            powershell_exec ("Set-VM -Name #{name} #{dynmem} -MemoryStartupBytes #{definition.memory_size}MB -ProcessorCount #{definition.cpu_count}")
          end

          #TODO: #setting video memory size
          #command="#{@vboxcmd} modifyvm \"#{name}\" --vram #{definition.video_memory_size}"
          #shell_exec("#{command}")

          #setting bootorder
          powershell_exec ("Set-VMBios -VMName #{name} -StartupOrder @('CD', 'IDE', 'Floppy', 'LegacyNetworkAdapter')")

          #TODO: # Modify the vm to enable or disable extensions
=begin
          vm_flags=%w{pagefusion acpi ioapic pae hpet hwvirtex hwvirtexcl nestedpaging largepages vtxvpid synthxcpu rtcuseutc}

          vm_flags.each do |vm_flag|
            if definition.instance_variable_defined?("@#{vm_flag}")
              vm_flag_value=definition.instance_variable_get("@#{vm_flag}")
              ui.info "Setting VM Flag #{vm_flag} to #{vm_flag_value}"
              ui.warn "Used of #{vm_flag} is deprecated - specify your options in the definition file as \n :virtualbox => { :vm_options => [\"#{vm_flag}\" => \"#{vm_flag_value}\"]}"
              command="#{@vboxcmd} modifyvm #{name} --#{vm_flag.to_s} #{vm_flag_value}"
              shell_exec("#{command}")
            end
          end

          unless definition.virtualbox[:vm_options][0].nil?
            definition.virtualbox[:vm_options][0].each do |vm_flag,vm_flag_value|
              ui.info "Setting VM Flag #{vm_flag} to #{vm_flag_value}"
              command="#{@vboxcmd} modifyvm #{name} --#{vm_flag.to_s} #{vm_flag_value}"
              shell_exec("#{command}")
            end
          end
=end
        end
      end
    end
  end
end
