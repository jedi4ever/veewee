module Veewee
  module Provider
    module Vsphere
      module BoxCommand

        def destroy(options={})
          unless self.exists?
            raise Veewee::Error, "Error:: You tried to destroy a non-existing box '#{name}'"
          end

          raw.PowerOffVM_Task.wait_for_completion if raw.summary.runtime.powerState=="poweredOn"
	        raw.Destroy_Task.wait_for_completion
          # remove it from memory
          @raw=nil
        end
      end
    end
  end
end
