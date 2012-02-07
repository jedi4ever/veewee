module Veewee
  module Provider
    module Kvm
      module BoxCommand
        # Create a new vm
        def create(options={})
          # Assemble the Virtualmachine and set all the memory and other stuff"

          #memory_size,cpu_count, volume_size

          s=@connection.servers.create(
            :name => name,
            :memory_size => definition.memory_size.to_i*1024,
            :cpus => definition.cpu_count.to_i,
            :volume_capacity => "#{definition.disk_size}M",
            :network_interface_type => "nat",
            :iso_file => definition.iso_file,
            :arch => definition.os_type_id.end_with?("_64") ? "x86_64" : "i686",
            :iso_dir => env.config.veewee.iso_dir
          )
        end

        # Create the volume of a new vm
        def create_volume
          # Creating the volume is part of the server creation
        end

      end #End Module
    end # End Module
  end # End Module
end # End Module
