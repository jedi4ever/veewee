module Veewee
  module Provider
    module Vsphere
      module BoxCommand

        # Retrieve the first mac address for a vm
        # This will only retrieve the first auto generate mac address
        def mac_address
          raise Veewee::Error,"VM #{name} does not exist" unless self.exists?

          return raw.macs.first
        end

        # Retrieve the ip address for a vm.
        # Requires VMware Tools installed on the target VM
        def ip_address
          raise Veewee::Error,"VM #{name} does not exist" unless self.exists?

          return raw.guest_ip
        end

        # Retrieve host IP as seen by guest, assume this is same
        # as kickstart_ip provided in Veewee Configuration
        # TODO Figure out if there is a better way to accomplish this
        def host_ip_as_seen_by_guest
          ip = definition.vsphere[:kickstart_ip]
          raise Veewee::Error, "No ip defined for this machine in the definition file.\nThe following IP addresses are available:\n#{valid_host_ips}Please specify an IP address in the definition file using vsphere[:kickstart_ip]" if ip.nil? || '' == ip

          return ip
        end

        def valid_host_ips
          require 'socket'
          
          ipv4_addresses = Socket.ip_address_list.find_all { | ip | ip.ipv4? && !ip.ipv4_loopback? }

          return ipv4_addresses.reduce("") { | ip_list, ip | ip_list + "  " + ip.ip_address + "\n" }
        end

      end
    end
  end
end
