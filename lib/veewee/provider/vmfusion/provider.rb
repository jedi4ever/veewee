require 'veewee/provider/core/provider'
require 'veewee/provider/vmfusion/provider/validate_vmfusion'


module Veewee
  module Provider
    module Vmfusion
      class Provider < Veewee::Provider::Core::Provider

        include ::Veewee::Provider::Vmfusion::ProviderCommand

        def check_requirements
          #unless gem_available?("fission")
          #raise ::Veewee::Error, "The Vmfusion Provider requires the gem 'fission' to be installed\n"+ "gem install fission"
          #end
        end

        def build_info
          info=super
          command="/Library/Application Support/VMware Fusion/vmrun"
          output=IO.popen("#{command.shellescape}").readlines
          info << {:filename => ".vmfusion_version",:content => output[1].split(/ /)[2..3].join.strip}

        end


        # Transfer information provide by the provider to the box
        #
        #
        def transfer_buildinfo(box,definition)
          super(box,definition)

          # When we get here, ssh is available and no postinstall scripts have been executed yet
          # So we begin by transferring the ISO file of the vmware tools

          iso_image="/Library/Application Support/VMware Fusion/isoimages/linux.iso"
          iso_image="/Library/Application Support/VMware Fusion/isoimages/darwin.iso" if definition.os_type_id=~/^Darwin/
          iso_image="/Library/Application Support/VMware Fusion/isoimages/freebsd.iso" if definition.os_type_id=~/^Free/
          iso_image="/Library/Application Support/VMware Fusion/isoimages/windows.iso" if definition.os_type_id=~/^Win/

          env.logger.info "About to transfer vmware tools iso buildinfo to the box #{box.name} - #{box.ip_address} - #{ssh_options}"
          self.scp(iso_image,File.basename(iso_image))
        end




      end #End Class
    end # End Module
  end # End Module
end # End Module
