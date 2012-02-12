require 'nokogiri'

module Veewee
  module Provider
    module Kvm
      module BoxCommand
        # Create a new vm
        def create(options={})
          # Assemble the Virtualmachine and set all the memory and other stuff"


          create_server(options)
          create_volume(options)
          self.create_floppy("virtualfloppy.img")
        end

        def create_server(options)
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
        def create_volume(options)
          # Creating the volume is part of the server creation
        end

        def add_floppy
          # Get a raw libvirt connection
          c=@connection.raw

          # Retrieve the domain
          domain=c.lookup_domain_by_name(name)

          # Retrieve the existing XML from the domain
          domain_xml=domain.xml_desc

          # Convert the xml nokogiri doc
          domain_doc=Nokogiri::XML(domain_xml)

          # Find the device section
          devices=domain_doc.xpath('/domain/devices').first
          # The floppy xml representation
          floppy_xml="<disk type='file' device='floppy'><driver name='qemu' type='raw'/><source file='"+
          File.join(definitition.path,"virtualfloppy.img") +
          "'/><target dev='fda' bus='fdc'/><address type='drive' controller='0' bus='0' unit='0'/></disk>
          <controller type='fdc' index='0'>"

          # Convert the floppy xml to nokogiri
          floppy_doc=Nokogiri::XML(floppy_xml)

          # Add the floppy to the devices section
          devices.add_child(floppy_doc.root)

          # Get the raw xml of the changed document
          new_xml=domain_doc.to_xml

          # Undefine the existing domain 
          s.undefine

          # Re-define the domain
          c.define_domain_xml(new_xml)
        end

      end #End Module
    end # End Module
  end # End Module
end # End Module
