module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        def build_info
          info=super
          info << { :filename => ".vbox_version",
                    :content => "#{self.vbox_version}" }
        end

         # Transfer information provide by the provider to the box
         #
         #
         def transfer_buildinfo(options)
           super(options)
           iso_image="VBoxGuestAdditions_#{self.vbox_version}.iso"
           env.logger.info "About to transfer virtualbox guest additions iso to the box #{name} - #{ip_address} - #{ssh_options}"
           self.scp("#{File.join(env.config.veewee.iso_dir,iso_image)}",File.basename(iso_image))
         end

      end
    end
  end
end
