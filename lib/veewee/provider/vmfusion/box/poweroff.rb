module Veewee
  module Provider
    module Vmfusion
      module BoxCommand

        def poweroff(options={})
          raw.stop(:hard => true) unless raw.nil?
        end

      end
    end
  end
end
