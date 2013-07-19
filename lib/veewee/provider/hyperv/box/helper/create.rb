module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        #TODO: def attach_serial_console
          #command ="#{@vboxcmd} modifyvm \"#{name}\" --uart1 0x3F8 4"
          #shell_exec("#{command}")
          #command ="#{@vboxcmd} modifyvm \"#{name}\" --uartmode1 file \"#{File.join(FileUtils.pwd,name+"-serial-console"+".log")}\""
          #shell_exec("#{command}")
        #end

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

        def get_vbox_home
          command="#{@vboxcmd}  list  systemproperties"
          shell_results=shell_exec("#{command}")
          # On windows Default machine path would include a drive letter, then ':'.
          # So here we tell to split no more than 2 elements to keep the full path
          # This should work for all OS as we just need to separate the parameter name with first ':' from the value
          location=shell_results.stdout.split(/\n/).grep(/Default machine/)[0].split(":", 2)[1].strip
          return location
        end

        def suppress_messages
          day=24*60*60
          update_date=Time.now+365*day

          extraData = [
              ["GUI/RegistrationData","triesLeft=0"],
              ["GUI/SuppressMessages","confirmInputCapture,remindAboutAutoCapture,remindAboutMouseIntegrationOff,remindAboutMouseIntegrationOn,remindAboutWrongColorDepth"],
              ["GUI/UpdateDate", "1 d, #{update_date.year}-#{update_date.month.to_s.rjust(2,'0')}-#{update_date.day.to_s.rjust(2,'0')}, stable"],
              ["GUI/UpdateCheckCount","60"]
          ]
          extraData.each do |data|
            command="#{@vboxcmd} setextradata global \"#{data[0]}\" \"#{data[1]}\""
            shell_results=shell_exec("#{command}")
          end
        end

        def add_controller (controller_kind = 'ide')
          command ="#{@vboxcmd} storagectl \"#{name}\" --name \"#{controller_kind.upcase} Controller\" --add #{controller_kind}"
          shell_exec("#{command}")
        end

        def create_disk
          place=get_vbox_home
          1.upto(definition.disk_count.to_i) do |f|
            ui.info "Creating new harddrive of size #{definition.disk_size.to_i}, format #{definition.disk_format}, variant #{definition.disk_variant} "
            command ="#{@vboxcmd} createhd --filename \"#{File.join(place,name,name+"#{f}."+definition.disk_format.downcase)}\" --size \"#{definition.disk_size.to_i}\" --format #{definition.disk_format.downcase} --variant #{definition.disk_variant.downcase}"
            shell_exec("#{command}")
          end
        end

        def attach_disk(controller_kind, device_number)
          place=get_vbox_home

          1.upto(definition.disk_count.to_i) do |f|
            location=name+"#{f}."+definition.disk_format.downcase

            location="#{File.join(place,name,location)}"
            ui.info "Attaching disk: #{location}"

            #command => "${vboxcmd} storageattach \"${vname}\" --storagectl \"SATA Controller\" --port 0 --device 0 --type hdd --medium \"${vname}.vdi\"",
            command ="#{@vboxcmd} storageattach \"#{name}\" --storagectl \"#{controller_kind.upcase} Controller\" --port #{f-1} --device #{device_number} --type hdd --medium \"#{location}\" --nonrotational \"#{definition.nonrotational}\""
            shell_exec("#{command}")
          end
        end

        def attach_isofile(device_number = 0, port = 0, iso_file = definition.iso_file)
          full_iso_file=File.join(env.config.veewee.iso_dir, iso_file)
          ui.info "Mounting cdrom: #{full_iso_file}"
          command ="#{@vboxcmd} storageattach \"#{name}\" --storagectl \"IDE Controller\" --type dvddrive --port #{port} --device #{device_number} --medium \"#{full_iso_file}\""
          shell_exec("#{command}")
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
            floppy_file=File.join(definition.path,"virtualfloppy.vfd")
            ui.info "Mounting floppy: #{floppy_file}"
            command = pscmd ("Set-VMFloppyDiskDrive -VMName #{name} -Path #{floppy_file}")
            shell_exec("#{command}")
          end
        end

        def detach_floppy
          # Detach floppy to machine (the vfd extension is crucial to detect msdos type floppy)
          unless definition.floppy_files.nil?
            floppy_file=File.join(definition.path,"virtualfloppy.vfd")
            ui.info "Un-Mounting floppy: #{floppy_file}"
            command = pscmd ("Set-VMFloppyDiskDrive -VMName #{name} -Path ")
            shell_exec("#{command}")
          end
        end

        def hyperv_os_type_id(veewee_type_id)
          type=env.ostypes[veewee_type_id][:hyperv]
          env.logger.info("Using HyperV os_type_id #{type}")
          return type
        end

        def create_vm
          ui.info "Creating vm #{name} : #{definition.memory_size}M - #{definition.cpu_count} CPU - #{hyperv_os_type_id(definition.os_type_id)}"

          # Create a new named VM instance on the HyperV server
          command = pscmd ("New-VM -Server #{definition.hyperv_host} -Name #{name}")
          shell_exec("#{command}")

          command = pscmd ("Set-VM -Name #{name} -ComputerName #{name} -DynamicMemory #{definition.hyperv_dynamic_memory} -MemoryStartupBytes #{definition.memory_size} -ProcessorCount #{definition.cpu_count}")
          #setting cpu's
          #command = pscmd ("Set-VMProcessor -VMName #{name} -Count #{definition.cpu_count}")
          shell_exec("#{command}")

          #setting memory size
          #command = pscmd ("Set-VMMemory -VMName #{name} -DynamicMemoryEnabled #{definition.hyperv_dynamic_memory} -StartupBytes #{definition.memory_size}")
          #shell_exec("#{command}")

          #TODO: #setting video memory size
          #command="#{@vboxcmd} modifyvm \"#{name}\" --vram #{definition.video_memory_size}"
          #shell_exec("#{command}")

          #setting bootorder
          command pscmd ("Set-VMBios -VMName #{name} -StartupOrder @(\"CD\", \"IDE\”)")
          shell_exec("#{command}")

          #TODO: # Modify the vm to enable or disable hw virtualization extensions
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
