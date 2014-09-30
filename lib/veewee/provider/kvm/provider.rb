require 'veewee/provider/core/provider'

module Veewee
  module Provider
    module Kvm
      class Provider < Veewee::Provider::Core::Provider

        def check_requirements
          require 'fog'

          env.logger.info "Falling back to qemu:///system for libvirt URI if no value is specified in the .fog config file"
          Fog.credentials[:libvirt_uri] ||= "qemu:///system"

          env.logger.info "Setting libvirt IP Command if not already defined in .fog config file"
          Fog.credentials[:libvirt_ip_command] ||= "arp -an |grep -i $mac|cut -d '(' -f 2 | cut -d ')' -f 1"

          env.logger.info "Opening a libvirt connection using fog.io"
          begin

            unless gems_available?(["ruby-libvirt"])
              raise Veewee::Error, "Please install ruby-libvirt gem first"
            end
          end

          begin

            env.logger.info "Opening a libvirt connection using fog.io"
            conn = Fog::Compute[:libvirt]
          rescue Exception => ex
            raise Veewee::Error, "There was a problem opening a connection to libvirt: #{ex}"
          end
          env.logger.info "Libvirt connection established"

          env.logger.debug "Found capabilities:"
          env.logger.debug "#{conn.client.capabilities}"

          env.logger.info "Checking libvirt version"
          # http://www.libvirt.org/html/libvirt-libvirt.html#virGetVersion
          # format major * 1,000,000 + minor * 1,000 + release
          conn.client.libversion > 8003 or raise Veewee::Error, "You need at least libvirt version 0.8.3 or higher "

          env.logger.info "Checking available networks"
          conn.networks.any? or raise Veewee::Error, "You need at least one (active) network defined in #{Fog.credentials[:libvirt_uri]}."

          env.logger.info "Checking available storagepools"
          conn.pools.any? or raise Veewee::Error, "You need at least one (active) storage pool defined in #{Fog.credentials[:libvirt_uri]}."

          env.logger.info "Checking availability of the arp utility"
          shell_exec("arp -an").status.zero? or raise Veewee::Error, "Could not execute the arp command. This is required to find the IP address of the VM"

        end

        def build(definition_name, box_name, options)

          super(definition_name, box_name, options)

        end

      end #End Class
    end # End Module
  end # End Module
end # End Module
