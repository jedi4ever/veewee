module Veewee
  module Builder
    module Kvm
      
      def vol_exists?
        !@connection.volumes.all(:name => "#{@box_name}.img").nil?
      end
      
      def destroy(destroy_options={})
        if running?
          raise RuntimeError,"VM is running" unless !destroy_options["force"].nil?
          halt_vm
        end
        
        if exists?
          destroy_vm(destroy_options)
        end
        
        if vol_exists?
          destroy_disk(destroy_options)                 
        end

      end
      
	  end
	end
end
