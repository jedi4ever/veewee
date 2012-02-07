module Veewee
  module Provider
    module Vmfusion
      module BoxCommand

        # Get the IP address of the box
        def ip_address
          return raw.ip_address
        end

        # http://www.thirdbit.net/articles/2008/03/04/dhcp-on-vmware-fusion/
        def host_ip_as_seen_by_guest
          File.open("/Library/Application Support/VMware Fusion/vmnet8/nat.conf").readlines.grep(/ip = /).first.split(" ")[2]
        end

      end
    end
  end
end
