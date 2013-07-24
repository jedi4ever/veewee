module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        def hyperv_os_type_id(veewee_type_id)
          type = env.ostypes[veewee_type_id][:hyperv]
          env.logger.info("Using HyperV os_type_id #{type}")
          type
        end

        def create_vm
          if definition.memory_size.to_i < 512
            ui.warn "HyperV requires a minimum of 512MB RAM for a Guest OS, changing up from #{definition.memory_size}MB"
            definition.memory_size = "512"
          end

          env.logger.info "Creating VM #{name} : #{definition.memory_size}MB - #{definition.cpu_count} CPU - #{hyperv_os_type_id(definition.os_type_id)}"

          # Create a new named VM instance on the HyperV server
          powershell_exec("New-VM -Name #{name} -NewVHDSizeBytes #{definition.disk_size}MB -NewVHDPath '#{File.join(definition.hyperv_store_path,name,name).gsub('/', '\\')}-0.vhdx' -SwitchName #{definition.hyperv_network_name}")

          if (definition.memory_size.to_i > 512) || (definition.cpu_count.to_i > 2) || (definition.hyperv_dynamic_memory)
            dynmem = definition.hyperv_dynamic_memory ? "-DynamicMemory" : ""
            powershell_exec("Set-VM -Name #{name} #{dynmem} -MemoryStartupBytes #{definition.memory_size}MB -ProcessorCount #{definition.cpu_count}")
          end

          #TODO: #setting video memory size
          #command="#{@vboxcmd} modifyvm \"#{name}\" --vram #{definition.video_memory_size}"
          #shell_exec("#{command}")

          #setting bootorder
          powershell_exec("Set-VMBios -VMName #{name} -StartupOrder @('CD', 'IDE', 'Floppy', 'LegacyNetworkAdapter')")

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
