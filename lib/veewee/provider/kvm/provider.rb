require 'veewee/provider/core/provider'

module Veewee
  module Provider
    module Kvm
      class Provider < Veewee::Provider::Core::Provider

        # Translate the definition ssh options to ssh options that can be passed to Net::Ssh calls
        # We expect plain ssh for a connection

        def check_requirements
          ["ruby-libvirt","fog"].each do |gemname|
            unless gem_available?(gemname)
              raise Veewee::Error,"The kvm provider requires the gem '#{gemname}' to be installed\n"    + "gem install #{gemname}"
            end
          end

          env.logger.info "Checking for version of libvirt"
          begin
            require 'libvirt'
            env.logger.info "Opening a libvirt connection to qemu:///system"
            conn = ::Libvirt::open("qemu:///system")
            env.logger.info "Libvirt connection established"

            env.logger.info "Found capabilities:"
            env.logger.info "#{conn.capabilities}"

            env.logger.info "Checking available storagepools"
            pools=conn.list_storage_pools
            env.logger.info "Storagepools: #{pools.join(',')}"
            if pools.count < 1
              raise Veewee::Error,"You need at least one storage pool defined"
            end

            # http://www.libvirt.org/html/libvirt-libvirt.html#virGetVersion
            # format major * 1,000,000 + minor * 1,000 + release
            env.logger.info "Checking libvirt version"
            libvirt_version=conn.libversion
            if libvirt_version < 8003
              raise Veewee::Error,"You need at least libvirt version 0.8.3 or higher "
            end
            conn.close
          rescue Exception => ex
            raise Veewee::Error, "There was a problem opening a connection to libvirt: #{ex}"
          end

        end


        def build(definition_name,box_name,options)

          super(definition_name,box_name,options)

        end

      end #End Class
    end # End Module
  end # End Module
end # End Module
