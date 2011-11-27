require 'veewee/provider/core/box'
require 'veewee/provider/core/box/vnc'
require 'veewee/provider/kvm/box/validate_kvm'

module Veewee
  module Provider
    module Kvm
      class Box < Veewee::Provider::Core::Box

        include ::Veewee::Provider::Core
        include ::Veewee::Provider::Kvm

        include ::Veewee::Provider::Core::BoxCommand
        include ::Veewee::Provider::Kvm::BoxCommand

        attr_accessor :connection

        def initialize(name,env)

          require 'libvirt'
          require 'fog'

          super(name,env)

          @connection=::Fog::Compute.new(:provider => "Libvirt",
                                         :libvirt_uri => "qemu:///system",
                                         :libvirt_ip_command => "arp -an |grep $mac|cut -d '(' -f 2 | cut -d ')' -f 1")

        end

        # Type on the console
        def console_type(sequence,type_options={})
          vnc_port=@connection.servers.all(:name => name).first.vnc_port
          display_port=vnc_port.to_i - 5900
          env.ui.confirm "Sending keystrokes to VNC port :#{display_port} - TCP port: #{vnc_port}"
          vnc_type(sequence,"127.0.0.1",display_port)
        end


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

        # Destroy a vm
        def destroy(options={})
          if @connection.servers.all(:name => name).nil?
            env.ui.error "Error:: You tried to destroy a non-existing box '#{name}'"
            exit -1
          end

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

        def start(options={})
          matched_servers=@connection.servers.all(:name => name)
          matched_servers.first.start unless matched_servers.nil?
        end

        def halt(options={})
          matched_servers=@connection.servers.all(:name => name)
          matched_servers.first.halt unless matched_servers.nil?
        end

        def stop(options={})
          matched_servers=@connection.servers.all(:name => name)
          matched_servers.first.stop unless matched_servers.nil?
        end

        def ssh_options
          ssh_options={
            :user => definition.ssh_user,
            :port => 22,
            :password => definition.ssh_password,
            :timeout => definition.ssh_login_timeout.to_i
          }
          return ssh_options
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
