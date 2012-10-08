module Veewee
  module Provider
    module Vsphere
      module BoxCommand

        def up(options={})
          ui.info "Up called: running #{self.running?} or nil #{raw.nil?}"
          ui.info "Starting VM" unless ( raw.nil? or self.running? )
          raw.PowerOnVM_Task unless ( raw.nil? or self.running? )
        end

      end
    end
  end
end
