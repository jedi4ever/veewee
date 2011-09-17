require 'tempfile'

module Veewee
  module Builder
    module Kvm

      # This function 'assembles' the box based on the definition
      def assemble
        # This will also create the disk, and mount the isofile
        create_vm
      end

    end
  end
end
