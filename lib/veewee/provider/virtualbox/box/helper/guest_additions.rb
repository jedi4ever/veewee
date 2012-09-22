module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        def download_vbox_guest_additions_iso(options)
          version=self.vboxga_version
          isofile="VBoxGuestAdditions_#{version}.iso"
          url="http://download.virtualbox.org/virtualbox/#{version}/#{isofile}"
          ui.info "Downloading vbox guest additions iso v #{version} - #{url}"
          download_iso(url,isofile)
        end
      end
    end
  end
end
