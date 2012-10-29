module Veewee
  module Provider
    module Kvm
      module BoxCommand

        def validate_kvm(options)

          validate_tags( [ 'vbox', 'puppet', 'chef'],options)

        end
      end #Module

    end #Module
  end #Module
end #Module
