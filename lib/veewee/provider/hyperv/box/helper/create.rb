module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        def hyperv_os_type_id(veewee_type_id)
          type = env.ostypes[veewee_type_id][:hyperv]
          env.ui.info "Using HyperV os_type_id [#{type}]"
          type
        end

        def create_vm

          if definition.memory_size.to_i < 512
            env.ui.warn "HyperV requires a minimum of 512MB RAM for a Guest OS, changing up from [#{definition.memory_size}MB]"
            definition.memory_size = "512"
          end

          unless definition.disk_format.downcase == 'vhdx'
            env.ui.warn "HyperV only support the VHDX virtual hard drive format, changing from [#{definition.disk_format}]"
            definition.disk_format = 'vhdx'
          end

          vm_path = File.join(definition.hyperv_store_path,name).gsub('/', '\\').downcase
          vhd_path = File.join(vm_path,"#{name}-0.#{definition.disk_format}").gsub('/', '\\').downcase

          # Create a new named VM instance on the HyperV server
          env.ui.info "Creating VM [#{name}] #{definition.memory_size}MB - #{definition.cpu_count}CPU - #{hyperv_os_type_id(definition.os_type_id)}"
          powershell_exec "New-VM -Name #{name} -MemoryStartupBytes #{definition.memory_size}MB -NewVHDSizeBytes #{definition.disk_size}MB -NewVHDPath '#{vhd_path}' -SwitchName #{definition.hyperv_network_name}"

          #TODO: #setting video memory size
          #command="#{@vboxcmd} modifyvm \"#{name}\" --vram #{definition.video_memory_size}"
          #shell_exec("#{command}")

          # Setting bootorder
          env.ui.info "Setting VMBios boot order 'CD', 'IDE', 'Floppy', 'LegacyNetworkAdapter'"
          powershell_exec "Set-VMBios -VMName #{name} -StartupOrder @('CD', 'IDE', 'Floppy', 'LegacyNetworkAdapter')"

          dynamic_memory = nil
          smart_paging = nil

          unless definition.hyperv[:vm_options][0].nil?
            definition.hyperv[:vm_options][0].each do |vm_flag,vm_flag_value|
              env.ui.info "Setting VM Flag [#{vm_flag}] to [#{vm_flag_value}]"
              case vm_flag.to_s.downcase
                when 'dynamic_memory'
                  dynamic_memory = vm_flag_value ? '-DynamicMemory' : nil
                when 'smart_paging'
                  swp_path = File.join(vm_path,"#{name}.swp").gsub('/', '\\').downcase
                  smart_paging = vm_flag_value ? "-SmartPagingFilePath '#{swp_path}'" : nil
                else
                  env.ui.warn "Ignoring unsupported vm_flag [#{vm_flag}] with value [#{vm_flag_value}]"
              end
            end
          end

          env.ui.info "Setting VM SnapshotFileLocation and other vm options"
          powershell_exec "Set-VM -Name #{name} #{dynamic_memory} #{smart_paging} -SnapshotFileLocation '#{vm_path}\\snapshot\\'"

        end
      end
    end
  end
end
