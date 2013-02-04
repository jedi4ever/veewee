module Veewee
  module Provider
    module Vsphere
      module BoxCommand

        # Check if box is running
        def running?
          return false if raw.nil?
          return raw.summary.runtime.powerState=="poweredOn"
        end

        # Check if the box already exists
        def exists?
          return (not raw.nil?)
        end

      end
    end
  end
end
