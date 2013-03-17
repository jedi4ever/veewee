module Veewee
  module Provider
    module Vmfusion
      module BoxCommand

        # Retrieve the first mac address for a vm
        # This will only retrieve the first auto generate mac address
        def mac_address
          raise ::Fission::Error,"VM #{name} does not exist" unless self.exists?

          line=File.new(vmx_file_path).grep(/^ethernet0.generatedAddress =/)
          if line.nil?
            #Fission.ui.output "Hmm, the vmx file #{vmx_path} does not contain a generated mac address "
            return nil
          end
          address=line.first.split("=")[1].strip.split(/\"/)[1]
          return address
        end

        # Retrieve the ip address for a vm.
        # This will only look for dynamically assigned ip address via vmware dhcp
        def ip_address
          # Does not work for now as the vmx path is not escape correctly by fission 0.4.0
          #return raw.network_info.data.first['ip_address']
          raise ::Fission::Error,"VM #{name} does not exist" unless self.exists?
          
          # Use alternate method to retrieve the IP address using vmrun readVariable
          
          ip_address = shell_exec("#{vmrun_cmd.shellescape} readVariable \"#{vmx_file_path}\" guestVar ip", { :mute => true}).stdout.strip
          return ip_address unless ip_address.empty?
        
          unless mac_address.nil?
            lease = Fission::Lease.find_by_mac_address(mac_address).data
            return lease.ip_address unless lease.nil?
            return nil
          else
            # No mac address was found for this machine so we can't calculate the ip-address
            return nil
          end
        end

        # http://www.thirdbit.net/articles/2008/03/04/dhcp-on-vmware-fusion/
        def host_ip_as_seen_by_guest

          # if File.exists?("/Library/Application Support/VMware Fusion/vmnet8/nat.conf")
          #   file = "/Library/Application Support/VMware Fusion/vmnet8/nat.conf"
          # end

          # if File.exists?("/Library/Preferences/VMware Fusion/vmnet8/nat.conf")
          #   file = "/Library/Preferences/VMware Fusion/vmnet8/nat.conf"
          # end
          # File.open(file).readlines.grep(/ip = /).first.split(" ")[2]

          # The above is not always correct
          # There seems also an entry for vmnet8 in the dhcpd.conf
          # /Library/Preferences/VMware Fusion/vmnet8/dhcpd.conf
          # host vmnet8 {
          #   fixed-address

          # The above is fancy but doesn't always agree, we need to do is ifconfig vmnet8
          # Ifconfig never lies
          shell_results = shell_exec("ifconfig vmnet8", { :mute => true})
          shell_results.stdout.split(/\n/).grep(/inet /)[0].strip.split(/ /)[1]
        end

      end
    end
  end
end
