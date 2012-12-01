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
          # verify some stuff before trying to create the server
          kvm_options = definition.kvm[:vm_options][0]
          # Create the "server"
          attributes = {
            :name => name,
            :memory_size => definition.memory_size.to_i*1024,
            :cpus => definition.cpu_count.to_i,
            :volume_capacity => "#{definition.disk_size}M",
            :domain_type => options['use_emulation'] ? 'qemu': 'kvm',
            :iso_file => definition.iso_file,
            :arch => definition.os_type_id.end_with?("_64") ? "x86_64" : "i686",
            :iso_dir => env.config.veewee.iso_dir
          }
          # Check for network stuff (default, bridge)
          check_network(kvm_options, attributes)
          # Check for pool (storage)
          check_pool(kvm_options, attributes)
          s=@connection.servers.create(attributes)
        end

        # Check the network availability of the defined network for kvm
        def check_network(options, attributes)
          env.logger.info "Checking network"
          if options.nil? or options.empty? or options["network_type"].nil? or options["network_type"] == "network"
            check_default_network
            attributes[:network_interface_type] = "network"
          elsif options["network_type"] == "bridge"
            options["network_bridge_name"].nil?
            if options["network_bridge_name"].nil?
              raise Veewee::Error, "You need to specify a 'network_bridge_name' if you plan to use 'bridge' as network type"
            else
              attributes[:network_interface_type] = "bridge"
              attributes[:network_bridge_name] = "#{options["network_bridge_name"]}"
            end
          else
            raise Veewee::Error, "You specified a 'network_type' that isn't known (#{options["network_type"]})"
          end
        end

        def check_default_network
          # Nothing specified, we check for default network
          conn = ::Libvirt::open("qemu:///system")
          networks=conn.list_networks
          if networks.count < 1
            raise Veewee::Error, "You need at least one (active) network defined or customize your definition. This needs to be available if you connect to qemu:///system."
          end
        end

        # Check the given pool and append to attributes
        # Note: volume_pool_name is not working in fog library version 1.7.0.
        #       This should be fixed in the next release.
        def check_pool(options, attributes)
          env.logger.info "Checking pool storage"
          if not options.nil? and not options.empty? and not options["pool_name"].nil?
            conn = ::Libvirt::open("qemu:///system")
            # Checking if the pool exists and if it is active
            begin
              storage = conn.lookup_storage_pool_by_name(options["pool_name"])
            rescue Libvirt::RetrieveError
              raise Veewee::Error, "You've specified an non-existent storage pool (#{options["pool_name"]})"
            end
            if storage.active?
              attributes[:volume_pool_name] = options["pool_name"]
            else
              raise Veewee::Error, "The storage pool '#{options["pool_name"]}' is not started. Start it and restart the creation process"
            end
          end
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
