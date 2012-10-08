module Veewee
  module Provider
    module Vsphere
      module BoxCommand

        def build(options)
          super(options)
          close_vnc
        end

      end
    end
  end
end
