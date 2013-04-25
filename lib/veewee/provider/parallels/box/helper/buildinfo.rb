module Veewee
  module Provider
    module Parallels
      module BoxCommand

        def build_info
          info=super
          command="prlctl --version"
          output=IO.popen("#{command}").readlines
          info << {:filename => ".parallels_version",:content => output[0].split(/ /)[2]}

        end

        # Determine the iso of the guest additions
        def guest_iso_path
          # So we begin by transferring the ISO file of the vmware tools

          parallels_base_path = "/Applications/Parallels Desktop.app/Contents/Resources/Tools"

          # Set default
          iso_image="#{parallels_base_path}/prl-tools-lin.iso"
          iso_image="#{parallels_base_path}/prl-tools-mac.iso" if definition.os_type_id=~/^Darwin/
          iso_image="#{parallels_base_path}/prl-tools-win.iso" if definition.os_type_id=~/^Win/
          iso_image="#{parallels_base_path}/prl-tools-other.iso" if definition.os_type_id=~/^Free/
          iso_image="#{parallels_base_path}/prl-tools-other.iso" if definition.os_type_id=~/^Solaris/
          return iso_image

        end

        # Transfer information provide by the provider to the box
        #
        #
        def transfer_buildinfo(options)
          super(options)

          # When we get here, ssh is available and no postinstall scripts have been executed yet
          # So we begin by transferring the ISO file of the vmware tools

          ui.info "About to transfer parallels tools iso buildinfo to the box #{name} - #{ip_address} - #{ssh_options}"
          iso_image=guest_iso_path
          self.copy_to_box(iso_image,File.basename(iso_image))
        end

      end
    end
  end
end
