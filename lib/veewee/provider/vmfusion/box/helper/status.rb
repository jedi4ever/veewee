module Veewee
  module Provider
    module Vmfusion
      module BoxCommand

        # Check if box is running
        def running?
          return false if raw.nil?
          return raw.running?
        end

        # Check if the box already exists
        def exists?
          return raw.exists?
        end

      end
    end
  end
end
