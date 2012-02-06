module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        # http://www.virtualbox.org/manual/ch09.html#idp13716288
        def host_ip_as_seen_by_guest
          "10.0.2.2"
        end

        # Get the IP address of the box
        def ip_address
          return "127.0.0.1"
        end

      end
    end
  end
end
