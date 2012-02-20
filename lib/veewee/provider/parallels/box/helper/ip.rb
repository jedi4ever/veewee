module Veewee
  module Provider
    module Parallels
      module BoxCommand

        # Get the IP address of the box
        def ip_address
          mac=mac_address
          command="grep #{mac} /Library/Preferences/Parallels/parallels_dhcp_leases|cut -d '=' -f 1"
          ip=shell_exec("#{command}").stdout.strip.downcase
          return ip
        end

        def mac_address
          command="prlctl list -i '#{self.name}'|grep 'net0 (' | cut -d '=' -f 3 | cut -d ' ' -f 1 "
          mac=shell_exec("#{command}").stdout.strip.downcase
          return mac
        end

      end
    end
  end
end
