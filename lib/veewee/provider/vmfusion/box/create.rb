require 'erb'

module Veewee
  module Provider
    module Vmfusion
      module BoxCommand
        def create_disk
          #Disk types:
          #    0                   : single growable virtual disk
          #    1                   : growable virtual disk split in 2GB files
          #    2                   : preallocated virtual disk
          #    3                   : preallocated virtual disk split in 2GB files
          #    4                   : preallocated ESX-type virtual disk
          #    5                   : compressed disk optimized for streaming
          #    6                   : thin provisioned virtual disk - ESX 3.x and above
          disk_type=1
          current_dir=FileUtils.pwd
          FileUtils.chdir(vm_path)
          env.ui.info "Creating disk"
          command="#{fusion_path.shellescape}/vmware-vdiskmanager -c -s #{definition.disk_size}M -a lsilogic -t #{disk_type} #{name}.vmdk"
          shell_results=shell_exec("#{command}",{:mute => true})
          FileUtils.chdir(current_dir)
        end

        def fusion_os_type(type_id)
          env.logger.info "Translating #{type_id} into fusion type"
          fusiontype=env.ostypes[type_id][:fusion]
          env.logger.info "Found fusion type #{fusiontype}"
          return fusiontype
        end

        def create_vm
          fusion_definition=definition.dup

          fusion_definition.os_type_id=fusion_os_type(definition.os_type_id)

          FileUtils.mkdir_p(vm_path)
          current_dir=FileUtils.pwd
          FileUtils.chdir(vm_path)
          aFile = File.new(vmx_file_path, "w")
          aFile.write(vmx_template(fusion_definition))
          aFile.close
          FileUtils.chdir(current_dir)
        end

        def determine_vmrun_cmd
          return "#{fusion_path}/vmrun"
        end

        def vm_path
          home=ENV['HOME']
          dir="#{home}/Documents/Virtual Machines.localized/#{name}.vmwarevm"
          return dir
        end

        def fusion_path
          dir="/Library/Application Support/VMware Fusion/"
          return dir
        end

        def vmx_file_path
          return "#{vm_path}/#{name}.vmx"
        end

      end
    end
  end
end
