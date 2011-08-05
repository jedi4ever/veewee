module Veewee
  module Builder
    module Kvm
      
      def create_disk
        # Creating the disk is part of the server creation
      end

      def destroy_disk(destroy_options={})
        vol=@connection.volumes.all(:name => "#{@box_name}.img").first
        vol.destroy
      end
      
    end
  end
end

