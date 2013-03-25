module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        def windows_drivers_version
          return definition.windows_drivers_version
        end

        def windows_drivers_isoname
          return "virtio-win-#{self.windows_drivers_version}.iso"
        end

        def download_windows_drivers_iso(options)
          version=self.windows_drivers_version
          isofile=self.windows_drivers_isoname
          url="http://alt.fedoraproject.org/pub/alt/virtio-win/latest/images/bin/#{isofile}"
          ui.info "Downloading virtualbox drivers iso #{version} - #{url}"
          download_iso(url,isofile)
        end
      end
    end
  end
end
