require 'veewee/builder/core/builder'

module Veewee
  module Builder
    module Vmfusion
      class Builder < Veewee::Builder::Core::Builder

          def assemble
            box.create()
          end
          
          def buildinfo()
#            ".vagrant_version"
#            3.1.2 build-332101
          end
                   
      end #End Class
    end # End Module
  end # End Module
end # End Module