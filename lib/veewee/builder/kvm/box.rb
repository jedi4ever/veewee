require 'veewee/util/shell'
require 'veewee/util/tcp'
require 'veewee/util/web'
require 'veewee/util/ssh'

require 'veewee/builder/core/box'

require 'veewee/builder/kvm/build'
require 'veewee/builder/kvm/assemble'
require 'veewee/builder/kvm/destroy'


module Veewee
  module Builder
    module Kvm
      class Box < Veewee::Builder::Core::Box
        include Veewee::Builder::Core
        include Veewee::Builder::Kvm

        attr_accessor :connection

        def initialize(environment,box_name,definition_name,box_options={})
          require 'libvirt'
          require 'fog'

          # We only do the internal build for now
          @connection=::Fog::Compute.new(:provider => "Libvirt", :libvirt_uri => "qemu:///system")

          super(environment,box_name,definition_name,box_options)
        end

        # Type on the console
        def console_type(sequence,type_options={})
                  vnc_port=raw.vnc_port
                  vnc_type(sequence,"localhost",vnc_port)
        end
                
        # Translate the definition ssh options to ssh options that can be passed to Net::Ssh calls
        # We expect plain ssh for a connection
        def ssh_options
          ssh_options={
            :user => @definition.ssh_user,
            :port => 22,
            :password => @definition.ssh_password,
            :timeout => @definition.ssh_login_timeout.to_i
          }
          return ssh_options

        end

        def destroy(destroy_options={})
          matched_servers=@connection.servers.all(:name => name)
          matched_servers.first.destroy unless matched_servers.nil?
        end

        def start
          matched_servers=@connection.servers.all(:name => name)
          matched_servers.first.start unless matched_servers.nil?
        end

        def halt_
          matched_servers=@connection.servers.all(:name => name)
          matched_servers.first.halt unless matched_servers.nil?
        end

        def stop_
          matched_servers=@connection.servers.all(:name => name)
          matched_servers.first.stop unless matched_servers.nil?
        end
        
        def ip_address
          ip=@connection.servers.all(:name => "#{@box_name}").first.addresses[:public]
          return ip.first unless ip.nil?
          return ip
        end
        

        def create
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

        def running?
          if exists?
            @connection.servers.all(:name => name).first.ready?
          else
            false
          end
        end

        def exists?
          !@connection.servers.all(:name => name).nil?
        end

      end # End Class
    end # End Module
  end # End Module
end # End Module
