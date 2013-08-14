module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        def host_ip_as_seen_by_guest
          return defition.host_ip_as_seen_by_box if defition.host_ip_as_seen_by_box
        else
          self.get_local_ip
        end

        # Get the IP address of the box
        def ip_address
          if definition.box_ip
            return definition.box_ip
          else
            return '127.0.0.1'
          end
        end

      end
    end
  end
end
