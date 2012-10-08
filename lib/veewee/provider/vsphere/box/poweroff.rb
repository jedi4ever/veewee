module Veewee
  module Provider
    module Vsphere
      module BoxCommand

        def poweroff(options={})
          raw.PowerOffVM_Task unless raw.nil?
        end

      end
    end
  end
end
