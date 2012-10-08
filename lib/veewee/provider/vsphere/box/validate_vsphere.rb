module Veewee
  module Provider
    module Vsphere
      module BoxCommand

        def validate_vsphere(options)
          validate_tags( options['tags'],options)
        end
      end #Module

    end #Module
  end #Module
end #Module
