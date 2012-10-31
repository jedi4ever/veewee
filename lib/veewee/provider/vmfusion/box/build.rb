

module Veewee
  module Provider
    module Vmfusion
      module BoxCommand

        def build(options)
          super(options)
          add_share_from_defn
        end
      end
    end
  end
end
