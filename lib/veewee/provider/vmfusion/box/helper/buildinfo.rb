module Veewee
  module Provider
    module Vmfusion
      module BoxCommand

        def build_info
          info=super
          command="/Library/Application Support/VMware Fusion/vmrun"
          output=IO.popen("#{command.shellescape}").readlines
          info << {:filename => ".vmfusion_version",:content => output[1].split(/ /)[2..3].join.strip}

        end

        # Determine the iso of the guest additions
        def guest_iso_path
          # So we begin by transferring the ISO file of the vmware tools

          iso_image="/Library/Application Support/VMware Fusion/isoimages/linux.iso"
          iso_image="/Library/Application Support/VMware Fusion/isoimages/darwin.iso" if definition.os_type_id=~/^Darwin/
          iso_image="/Library/Application Support/VMware Fusion/isoimages/freebsd.iso" if definition.os_type_id=~/^Free/
          iso_image="/Library/Application Support/VMware Fusion/isoimages/windows.iso" if definition.os_type_id=~/^Win/
          return iso_image

        end

        # Transfer information provide by the provider to the box
        #
        #
        def transfer_buildinfo(options)
          super(options)

          # When we get here, ssh is available and no postinstall scripts have been executed yet
          # So we begin by transferring the ISO file of the vmware tools

          env.logger.info "About to transfer vmware tools iso buildinfo to the box #{name} - #{ip_address} - #{ssh_options}"
          iso_image=guest_iso_path
          self.copy_to_box(iso_image,File.basename(iso_image))
        end

      end
    end
  end
end
