
module Veewee
  module Builder
    module Kvm

      def destroy_vm(destroy_options={})
        @connection.servers.all(:name => @box_name).first.destroy
      end

      def start_vm
        @connection.servers.all(:name => @box_name).first.start
      end

      def halt_vm
        @connection.servers.all(:name => @box_name).first.halt
      end
      
      def stop_vm
        @connection.servers.all(:name => @box_name).first.stop
      end
      
      def create_vm
        # Assemble the Virtualmachine and set all the memory and other stuff
        
        s=@connection.servers.create(:template_options => { 
          :name => @box_name,
          :interface_type => "bridge",
          :iso_file => @definition.iso_file ,
          :iso_dir => "/home/patrick.debois/iso",
          :type => "raw"
        })

        end

      end
    end
  end
