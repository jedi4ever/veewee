require 'veewee/builder/core/box'
require 'veewee/builder/core/box/vnc'

module Veewee
  module Builder
    module Kvm
      class Box < Veewee::Builder::Core::Box
        
        include ::Veewee::Builder::Core
        include ::Veewee::Builder::Kvm
        
        include ::Veewee::Builder::Core::BoxCommand
        
        attr_accessor :connection

        def initialize(name,env)

          require 'libvirt'
          require 'fog'

          super(name,env)
          
          @connection=::Fog::Compute.new(:provider => "Libvirt", :libvirt_uri => "qemu:///system")
          
        end
        
        # Type on the console
        def console_type(sequence,type_options={})
                  vnc_port=@connection.servers.all(:name => name).first.vnc_port
                  display_port=vnc_port.to_i - 5900
                  vnc_type(sequence,"localhost",display_port)
        end
                
        
        # Create a new vm
        def create(definition)
          # Assemble the Virtualmachine and set all the memory and other stuff"

          #memory_size,cpu_count, volume_size

          s=@connection.servers.create(
            :name => name,
            :network_interface_type => "nat",
            :iso_file => definition.iso_file ,
            #:arch => "" x86_64 / x86
            :iso_dir => env.config.veewee.iso_dir,
            #:volume_format_type => "img"
            )
        end
        
        # Create the volume of a new vm
        def create_volume
          # Creating the volume is part of the server creation
        end
        
        # Destroy a vm
        def destroy
          halt if running?
          destroy_vm if exists_vm?
          
          vol_exists=!@connection.volumes.all(:name => "#{name}.img").nil?
          env.logger.info "Volume exists? : #{vol_exists}"
          destroy_volume if exists_volume?
        end
        
        def destroy_vm
          matched_servers=@connection.servers.all(:name => name)
          matched_servers.first.destroy() unless matched_servers.nil?
        end

        def destroy_volume
          vol=@connection.volumes.all(:name => "#{name}.img").first
          vol.destroy
        end
        
        def start(mode)
          matched_servers=@connection.servers.all(:name => name)
          matched_servers.first.start unless matched_servers.nil?
        end

        def halt
          matched_servers=@connection.servers.all(:name => name)
          matched_servers.first.halt unless matched_servers.nil?
        end

        def stop
          matched_servers=@connection.servers.all(:name => name)
          matched_servers.first.stop unless matched_servers.nil?
        end
        
        def ip_address
          ip=@connection.servers.all(:name => "#{name}").first.addresses[:public]
          return ip.first unless ip.nil?
          return ip
        end
        
        def running?
          if exists_vm?
            @connection.servers.all(:name => name).first.ready?
          else
            false
          end
        end

        def exists?
          exists_volume? || exists_vm?
        end
        
        def exists_volume?
          !@connection.volumes.all(:name => "#{name}.img").nil?
        end
        
        def exists_vm?
          !@connection.servers.all(:name => name).nil?
        end

      end # End Class
    end # End Module
  end # End Module
end # End Module
