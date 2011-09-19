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
                  vnc_port=raw.vnc_port
                  vnc_type(sequence,"localhost",vnc_port)
        end
                
        # Translate the definition ssh options to ssh options that can be passed to Net::Ssh calls
        # We expect plain ssh for a connection
        def ssh_options(definition)
          ssh_options={
            :user => definition.ssh_user,
            :port => 22,
            :password => definition.ssh_password,
            :timeout => definition.ssh_login_timeout.to_i
          }
          return ssh_options

        end
        
        # Create a new vm
        def create(definition)
          # Assemble the Virtualmachine and set all the memory and other stuff"

          #memory_size,cpu_count, disk_size

          s=@connection.servers.create(
            :name => name,
            :network_interface_type => "nat",
            :iso_file => definition.iso_file ,
            #:arch => ""
            :iso_dir => env.config.veewee.iso_dir,
            #:volume_format_type => "img"
            )
        end
        
        # Create the disk of a new vm
        def create_disk
          # Creating the disk is part of the server creation
        end
        
        # Destroy a vm
        def destroy
          halt if running?
          destroy_vm if exists?
          
          vol_exists=!@connection.volumes.all(:name => "#{name}.img").nil?
          env.logger.info "Volume exists? : #{vol_exists}"
          destroy_disk if self.vol_exists
        end
        
        def destroy_vm
          matched_servers=@connection.servers.all(:name => name)
          matched_servers.first.destroy() unless matched_servers.nil?
        end

        def destroy_disk
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
          if exists?
            @connection.servers.all(:name => name).first.ready?
          else
            false
          end
        end

        def exists?
          (!@connection.servers.all(:name => name).nil?) || (!@connection.volumes.all(:name => "#{name}.img").nil?)
        end

      end # End Class
    end # End Module
  end # End Module
end # End Module
