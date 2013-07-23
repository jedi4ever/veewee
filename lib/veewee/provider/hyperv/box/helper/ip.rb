module Veewee
  module Provider
    module Hyperv
      module BoxCommand

        def host_ip_as_seen_by_guest
          "10.0.2.2"
        end

        # Get the IP address of the box
        def ip_address
          if (definition.veewee_ip)
            return definition.veewee_ip
          else
            return "127.0.0.1"
          end

        end

      end
    end
  end
end
