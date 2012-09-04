module Veewee
  module Provider
    module Parallels
      module BoxCommand

        def validate_parallels(options)
          validate_tags([ 'parallels','puppet','chef'],options)
        end
      end #Module

    end #Module
  end #Module
end #Module
