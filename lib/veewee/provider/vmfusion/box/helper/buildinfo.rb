module Veewee
  module Provider
    module Vmfusion
      module BoxCommand

        def build_info
          info=super
          output=IO.popen("#{vmrun_cmd.shellescape}").readlines
          info << {:filename => ".vmfusion_version",:content => @provider.fusion_version }
        end


       def guest_iso_directory
          # use vmware fusion 3.x as default path
          iso_images_dir="/Library/Application Support/VMware Fusion/isoimages"

          # if path doesn't exist check for vmware fusion >= 4.x path
          if( ! File.exists?(iso_images_dir) )
            iso_images_dir="/Applications/VMware Fusion.app/Contents/Library/isoimages"
          end
          return iso_images_dir
        end

        # Determine the iso of the guest additions
        def guest_iso_path
          # So we begin by transferring the ISO file of the vmware tools
          iso_image=File.join(guest_iso_directory, "linux.iso")
          iso_image=File.join(guest_iso_directory, "darwin.iso") if definition.os_type_id=~/^Darwin/
          iso_image=File.join(guest_iso_directory, "freebsd.iso") if definition.os_type_id=~/^Free/
          iso_image=File.join(guest_iso_directory, "windows.iso") if definition.os_type_id=~/^Win/
          return iso_image
        end

        # Transfer information provide by the provider to the box
        #
        #
        def transfer_buildinfo(options)
          super(options)

          # Initialize download_tools to true if null
          if definition.vmfusion[:vm_options]['download_tools'].nil?
            definition.vmfusion[:vm_options]['download_tools'] = true 
          end

          # When we get here, ssh is available and no postinstall scripts have been executed yet
          # So we begin by transferring the ISO file of the vmware tools
          if !(definition.winrm_user && definition.winrm_password) && definition.vmfusion[:vm_options]['download_tools']
            # with windows, we just use the mounted volume
            env.logger.info "About to transfer vmware tools iso buildinfo to the box #{name} - #{ip_address} - #{ssh_options}"
            iso_image=guest_iso_path
            if File.exists?(iso_image)
              self.copy_to_box(iso_image,File.basename(iso_image))
            else
              raise Veewee::Error, "We could not find the file #{iso_image}. In newer versions of Fusion, you might have to download the Guest Additions yourself. You can do this by first manually creating a vm and than 'installing the guest additions'"
            end
          end
        end

      end
    end
  end
end
