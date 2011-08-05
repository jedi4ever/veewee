module Veewee
  module Builder
    module Vmfusion

      def mac_address
        unless File.exists?(vmx_file_path)
          return nil
        else
          line=File.new(vmx_file_path).grep(/^ethernet0.generatedAddress =/)
          if line.nil?
            puts "Hmm, the vmx files is not valid"
            raise "invalid vmx file #{vmx_file_path}"
          end
          address=line.first.split("=")[1].strip.split(/\"/)[1]
          return address
        end
      end

      def ip_address
        #http://nileshk.com/2009/06/24/vmware-fusion-nat-dhcp-and-port-forwarding.html
        #http://works13.com/blog/mac/ssh-your-arch-linux-vm-in-vmware-fusion.htm

        #       /var/db/vmware/vmnet-dhcpd-vmnet8.leases
        #
        #       lease 172.16.44.134 {
        #       	starts 4 2011/07/28 15:54:41;
        #       	ends 4 2011/07/28 16:24:41;
        #       	hardware ethernet 00:0c:29:54:06:5c;
        #       }
        unless mac_address.nil?
          index=File.new("/var/db/vmware/vmnet-dhcpd-vmnet8.leases").grep(/hardware /).index{ |x| x.include?(mac_address)}
          ip=File.new("/var/db/vmware/vmnet-dhcpd-vmnet8.leases").grep(/^lease/)[index].split(/ /)[1]
          return ip
        else
          return nil
        end
      end

    end
  end
end