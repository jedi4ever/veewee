require 'tempfile'

module Veewee
  module Builder
    module Virtualbox
      
      # This function 'assembles' the box based on the definition
      def assemble
        create_vm
        
        # Adds a folder to the vm for testing purposes
        add_shared_folder

        #Create a disk with the same name as the box_name
        create_disk

        add_ide_controller
        attach_isofile
        
        add_sata_controller
        attach_disk
        
        create_floppy
        add_floppy_controller
        attach_floppy
        
        add_ssh_nat_mapping
        
      end
      






    end #End Module
  end #End Module
end #End Module
