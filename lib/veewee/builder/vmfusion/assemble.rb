require 'tempfile'

module Veewee
  module Builder
    module Vmfusion
      
      # This function 'assembles' the box based on the definition
      def assemble
        create_vm
        create_disk
      end
      
    end
  end
end