module Veewee
  module Provider
    module Parallels
      module BoxCommand

        # When we create a new box
        # We assume the box is not running
        def create(options)
          create_vm
          create_disk
          #self.create_floppy("virtualfloppy.img")
        end


        def create_disk
        end

        def parallels_os_type(type_id)
          env.logger.info "Translating #{type_id} into parallels type"
          parallelstype=env.ostypes[type_id][:parallels]
          env.logger.info "Found Parallels type #{parallelstype}"
          return parallelstype
        end

        def create_vm
          parallels_definition=definition.dup
          distribution=parallels_os_type(definition.os_type_id)

          # Create the vm
          command="prlctl create '#{self.name}' --distribution '#{distribution}'"
          shell_exec("#{command}")
          command="prlctl set '#{self.name}' --cpus #{definition.cpu_count} --memsize #{definition.memory_size}"
          shell_exec("#{command}")


          #NOTE: order is important: as this determines the boot order sequence
          #
          # Remove the network to disable pxe boot
          command="prlctl set '#{self.name}' --device-del net0"
          shell_exec("#{command}")

          # Remove default cdrom
          command ="prlctl set '#{self.name}' --device-del cdrom0"
          shell_exec("#{command}")
          #
          # Attach cdrom
          full_iso_file=File.join(env.config.veewee.iso_dir,definition.iso_file)
          ui.info "Mounting cdrom: #{full_iso_file}"
          command ="prlctl set '#{self.name}' --device-add cdrom --enable --image '#{full_iso_file}'"
          shell_exec("#{command}")

          #Enable the network again
          command="prlctl set '#{self.name}' --device-add net --enable --type shared"
          shell_exec("#{command}")



        end

      end
    end
  end
end
