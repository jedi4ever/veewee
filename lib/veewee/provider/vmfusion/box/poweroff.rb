module Veewee
  module Provider
    module Vmfusion
      module BoxCommand

        def poweroff(options={})
          raw.halt unless raw.nil?
        end

      end
    end
  end
end
