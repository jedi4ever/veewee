module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        def validate_vagrant(options = {})
          validate_tags( options['tags'],options)
        end
      end #Module

    end #Module
  end #Module
end #Module
