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

        def attach_disk(controller_kind,device_number)
          1.upto(definition.disk_count.to_i) do |f|
            powershell_exec("Add-VMHardDiskDrive -VMName #{name} -ControllerNumber #{device_number} -ControllerLocation #{f-1} ")
          end
        end

        def attach_isofile(device_number = 0,port = 0,iso_file = definition.iso_file)
          local_iso_file = File.join(env.config.veewee.iso_dir,iso_file).gsub('/', '\\')
          remote_iso_file = File.join("\\\\",definition.hyperv_host,"veewee",iso_file ).gsub('/', '\\')
          env.logger.info "Copying ISO file [#{local_iso_file}] to HyperV Host"
          result = powershell_exec "if (Test-Path -Path '#{remote_iso_file}') {'true' ; exit} else {Copy-Item -Path '#{local_iso_file}' -Destination '#{remote_iso_file}'}",{:remote => false}
          status = (result.stdout.chomp == 'true') ? true : false
          env.logger.info "Remote file [#{remote_iso_file}] already exists on HyperV Host and will be re-used" if status
          env.logger.info "Mounting ISO: #{remote_iso_file}"
          powershell_exec "Set-VMDvdDrive -VMName #{name} -Path '#{remote_iso_file}'"
        end

        def detach_isofile(device_number = 0,port = 0)
          full_iso_file = File.join(env.config.veewee.iso_dir,definition.iso_file).gsub('/', '\\')
          ui.info "Un-Mounting cdrom: #{full_iso_file}"
          command ="#{@vboxcmd} storageattach \"#{name}\" --storagectl \"IDE Controller\" --type dvddrive --port #{port} --device #{device_number} --medium emptydrive"
          shell_exec("#{command}")
        end

        def detach_guest_additions(device_number = 0,port = 1)
          full_iso_file = File.join(env.config.veewee.iso_dir,"VBoxGuestAdditions_#{self.vboxga_version}.iso").gsub('/', '\\')
          ui.info "Un-Mounting guest additions: #{full_iso_file}"
          command ="#{@vboxcmd} storageattach \"#{name}\" --storagectl \"IDE Controller\" --type dvddrive --port #{port} --device #{device_number} --medium emptydrive"
          shell_exec("#{command}")
        end

        def attach_floppy
          # Attach floppy to machine (the vfd extension is crucial to detect msdos type floppy)
          unless definition.floppy_files.nil?
            local_floppy_file = File.join(definition.path,"virtualfloppy.vfd").gsub('/', '\\')
            remote_floppy_file = File.join("\\\\",definition.hyperv_host,"veewee","virtualfloppy.vfd").gsub('/', '\\')
            powershell_exec("Copy-Item -Path '#{local_floppy_file}' -Destination '#{remote_floppy_file}'",{:remote => false})
            ui.info "Mounting floppy: #{remote_floppy_file}"
            powershell_exec("Set-VMFloppyDiskDrive -VMName #{name} -Path '#{remote_floppy_file}'")
          end
        end

        def detach_floppy
          # Detach floppy to machine (the vfd extension is crucial to detect msdos type floppy)
          unless definition.floppy_files.nil?
            floppy_file = File.join(definition.path,"virtualfloppy.vfd").gsub('/', '\\')
            ui.info "Un-Mounting floppy: #{floppy_file}"
            powershell_exec("Set-VMFloppyDiskDrive -VMName #{name} -Path")
          end
        end

      end
    end
  end
end