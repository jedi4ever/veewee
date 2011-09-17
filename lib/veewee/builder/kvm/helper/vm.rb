module Veewee
  module Builder
    module Kvm

      def destroy_vm(destroy_options={})
        matched_servers=@connection.servers.all(:name => @box_name)
        matched_servers.first.destroy unless matched_servers.nil?
      end

      def start_vm
        matched_servers=@connection.servers.all(:name => @box_name)
        matched_servers.first.start unless matched_servers.nil?
      end

      def halt_vm
        matched_servers=@connection.servers.all(:name => @box_name)
        matched_servers.first.halt unless matched_servers.nil?
      end

      def stop_vm
        matched_servers=@connection.servers.all(:name => @box_name)
        matched_servers.first.stop unless matched_servers.nil?
      end

      def create_vm
        # Assemble the Virtualmachine and set all the memory and other stuff

        # If local it's just currentdir+iso or the one specified
        iso_dir="iso"

        # If remote, request homedir + iso?

        s=@connection.servers.create(
          :name => @box_name,
          :network_interface_type => "bridge",
          :iso_file => @definition.iso_file ,
          :iso_dir => "/home/patrick.debois/iso",
          :type => "raw")
        end

      end
    end
  end
