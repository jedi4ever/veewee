module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        #TODO: def add_shared_folder
        #  command="#{@vboxcmd} sharedfolder add  \"#{name}\" --name \"veewee-validation\" --hostpath \"#{File.expand_path(env.validation_dir)}\" --automount"
        #  shell_exec("#{command}")
        #end

        def add_controller(controller_kind = 'scsi')
          case controller_kind
            when 'scsi'
              powershell_exec("Add-VMScsiController -VMName #{name}")
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

        def attach_isofile(device_number = 0,port = 0,iso_file = definition.iso_file)
          local_file = File.join(env.config.veewee.iso_dir,iso_file).gsub('/', '\\')
          remote_file = File.join("\\\\",definition.hyperv_host,'veewee',iso_file ).gsub('/', '\\')
          env.ui.info "Copying ISO file [#{local_file}] to HyperV Host"
          result = powershell_exec "if (Test-Path -Path '#{remote_file}') {'true' ; exit} else {Copy-Item -Path '#{local_file}' -Destination '#{remote_file}'}",{:remote => false}
          status = (result.stdout.chomp == 'true') ? true : false
          env.ui.info "Remote file [#{remote_file}] already exists on HyperV Host and will be re-used" if status
          remote_file = File.join("e:\\",'veewee',iso_file ).gsub('/', '\\')
          env.ui.info "Mounting cdrom: #{remote_file}"
          powershell_exec "Set-VMDvdDrive -VMName #{name} -Path '#{remote_file}' -ControllerNumber #{device_number} -ControllerLocation #{port}" if port == 0
          powershell_exec "Add-VMDvdDrive -VMName #{name} -Path '#{remote_file}' -ControllerNumber #{device_number} -ControllerLocation #{port}" if port == 1
        end

        def detach_isofile(device_number = 0,port = 0)
          env.ui.info "Un-Mounting cdrom on controller #{device_number} and port #{port}"
          powershell_exec "Set-VMDvdDrive -VMName #{name} -ControllerNumber #{device_number} -ControllerLocation #{port} -Path $null"
        end

        def attach_floppy
          # Attach floppy to machine (the vfd extension is crucial to detect msdos type floppy)
          local_file = File.join(definition.path,"virtualfloppy.vfd").gsub('/', '\\')
          remote_file = File.join("\\\\",definition.hyperv_host,'veewee','virtualfloppy.vfd').gsub('/', '\\')
          env.ui.info "Copying VirtualFloppy file [#{local_file}] to HyperV Host"
          result = powershell_exec "if (Test-Path -Path '#{remote_file}') {'true' ; exit} else {Copy-Item -Path '#{local_file}' -Destination '#{remote_file}'}",{:remote => false}
          status = (result.stdout.chomp == 'true') ? true : false
          env.ui.info "Remote file [#{remote_file}] already exists on HyperV Host and will be re-used" if status
          remote_file = File.join("e:\\",'veewee','virtualfloppy.vfd').gsub('/', '\\')
          env.ui.info "Mounting VirutalFloppy: #{remote_file}"
          powershell_exec("Set-VMFloppyDiskDrive -VMName #{name} -Path '#{remote_file}'")
        end

        def detach_floppy
          env.ui.info "Un-Mounting floppy"
          powershell_exec("Set-VMFloppyDiskDrive -VMName #{name} -Path $null")
        end

      end
    end
  end
end