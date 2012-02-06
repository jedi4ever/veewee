module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        def build(options={})
          download_vbox_guest_additions_iso(options)
          super(options)
        end

      end
    end
  end
end
