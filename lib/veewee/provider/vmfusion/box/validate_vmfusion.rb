module Veewee
  module Provider
    module Vmfusion
      module BoxCommand

        def validate_vmfusion(options)
          validate_tags( options['tags'],options)
        end
      end #Module

    end #Module
  end #Module
end #Module
