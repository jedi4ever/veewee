require 'nokogiri'
require 'fileutils'

module Veewee
  module Provider
    module Kvm
      module BoxCommand
        # Create a new vm
        def create(options={})
          # Assemble the Virtualmachine and set all the memory and other stuff"
          create_server(options)
          create_volume(options)
          add_virtio_drivers if File.exists?(File.join(definition.path, 'Autounattend.xml'))
          self.create_floppy("virtualfloppy.img")
          FileUtils.move(File.join(definition.path, 'Autounattend.xml.virtio'), File.join(definition.path, 'Autounattend.xml')) if File.exists?(File.join(definition.path, 'Autounattend.xml.virtio'))
          add_floppy unless definition.floppy_files.nil?
        end

        def create_server(options)

          # set volume pool name to user specified volume pool and fall back to first available volume pool
          if options["pool_name"]
            raise Veewee::Error, "Specified storage pool #{options["pool_name"]} does not exist" if @connection.pools.select { |pool| pool.name == options["pool_name"] }.empty?
            volume_pool_name = options["pool_name"]
          end
          volume_pool_name ||= @connection.pools.first.name
          env.logger.info "Using storage pool #{volume_pool_name}"

          # set network name to user specified network and fall back to default network or first available network
          if options["network_name"]
            raise Veewee::Error, "Specified network #{options["network_name"]} does not exist" if @connection.networks.select { |net| net.name == options["network_name"] }.empty?
            network_name = options["network_name"]
          end
          network_name ||= "default" unless @connection.networks.select { |net| net.name == 'default' }.empty?
          network_name ||= @connection.networks.first.name
          env.logger.info "Using network #{network_name}"

          # Create the "server"
          attributes = {
              :name => name,
              :memory_size => definition.memory_size.to_i*1024,
              :cpus => definition.cpu_count.to_i,
              :volume_capacity => "#{definition.disk_size}M",
              :domain_type => options['use_emulation'] ? 'qemu' : 'kvm',
              :iso_file => definition.iso_file,
              :arch => definition.os_type_id.end_with?("_64") ? "x86_64" : "i686",
              :iso_dir => env.config.veewee.iso_dir,
              :volume_pool_name => volume_pool_name,
              :volume_format_type => definition.disk_format,
              :network_nat_network => network_name
          }

          @connection.servers.create(attributes)
        end

        # Create the volume of a new vm
        def create_volume(options)
          # Creating the volume is part of the server creation
        end

        def add_floppy
          env.logger.info 'Adding floppy disk'
          # Get a raw libvirt connection
          conn = @connection.client

          # Retrieve the domain
          domain=conn.lookup_domain_by_name(name)

          # Retrieve the existing XML from the domain
          domain_xml=domain.xml_desc

          # Convert the xml nokogiri doc
          domain_doc=Nokogiri::XML(domain_xml)

          # Find the device section
          devices=domain_doc.xpath('/domain/devices').first
          # The floppy xml representation
          floppy_xml="<disk type='file' device='floppy'><driver name='qemu' type='raw'/><source file='"+
              File.join(definition.path, "virtualfloppy.img") +
              "'/><target dev='fda' bus='fdc'/><address type='drive' controller='0' bus='0' unit='0'/></disk>
          <controller type='fdc' index='0'>"

          # Convert the floppy xml to nokogiri
          floppy_doc=Nokogiri::XML(floppy_xml)

          # Add the floppy to the devices section
          devices.add_child(floppy_doc.root)

          # Get the raw xml of the changed document
          new_xml=domain_doc.to_xml

          # Undefine the existing domain
          domain.undefine

          # Re-define the domain
          conn.define_domain_xml(new_xml)
        end

        def add_virtio_drivers
          env.logger.info 'Adding virtio drivers for windows system to the virtual machine'
          # Get a raw libvirt connection
          conn = @connection.client

          # Retrieve the domain
          domain=conn.lookup_domain_by_name(name)

          # Retrieve the existing XML from the domain
          domain_xml=domain.xml_desc

          # Convert the xml nokogiri doc
          domain_doc=Nokogiri::XML(domain_xml)

          # Find the device section
          devices=domain_doc.xpath('/domain/devices').first

          # get latest version of virtio drivers
          url ='http://alt.fedoraproject.org/pub/alt/virtio-win/latest/images/bin/'
          filename = open(url).read.scan(/\"(virtio-win-.*.iso)\"/).first.first
          download_iso(url + filename, filename)
          path = File.join(env.config.veewee.iso_dir, filename)

          # The disk xml representation
          disk_xml="<disk type='file' device='cdrom'><driver name='qemu' type='raw'/><source file='" +
              path + "'/><target dev='hdd' bus='ide'/></disk>"

          # Convert the disk xml to nokogiri
          disk_doc=Nokogiri::XML(disk_xml)

          # Add the floppy to the devices section
          devices.add_child(disk_doc.root)

          # Get the raw xml of the changed document
          new_xml=domain_doc.to_xml

          # Undefine the existing domain
          domain.undefine

          # Re-define the domain
          conn.define_domain_xml(new_xml)

          env.logger.info 'Add search path for virtio drivers to Autounattend.xml'
          # parse Autoattend.xml to document
          FileUtils.copy(File.join(definition.path, 'Autounattend.xml'), File.join(definition.path, 'Autounattend.xml.virtio'))
          doc = Nokogiri::XML.parse(File.read(File.join(definition.path, 'Autounattend.xml')))
          # determine platform and windows version
          platform = definition.os_type_id.end_with?("_64") ? "amd64" : "x86"
          version = case definition.os_type_id.downcase
                      when /windows-?7/
                        'win7'
                      when /windows-?2008/
                        'win7'
                      when /windows-?8/
                        'win8'
                      when /xp/
                        'xp'
                      when /vista/
                        'vista'
                      else
                        raise 'could not determine windows version'
                    end
          # create new element
          component=Nokogiri::XML(%Q|<component name="Microsoft-Windows-PnpCustomizationsWinPE"
processorArchitecture="#{platform}" publicKeyToken="31bf3856ad364e35"
language="neutral" versionScope="nonSxS"
xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<DriverPaths>
<PathAndCredentials wcm:keyValue="1" wcm:action="add">
<Path>e:\\#{version}\\#{platform}</Path>
</PathAndCredentials>
</DriverPaths>
</component>|)
          doc.xpath('//unattend:settings[@pass="windowsPE"]', 'unattend' => 'urn:schemas-microsoft-com:unattend').first.add_child component.root

          file = File.open(File.join(definition.path, 'Autounattend.xml'), 'w')
          file.write(doc)
          file.close

        end

      end #End Module
    end # End Module
  end # End Module
end # End Module
