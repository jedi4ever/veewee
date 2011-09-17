module Veewee
  module Builder
    module Kvm

      def ip_address
        ip=@connection.servers.all(:name => "#{@box_name}").first.addresses[:public]
        return ip.first unless ip.nil?
        return ip
      end

      def web_ip_address
        unless @connection.uri.ssh_enabled?
          ip=Veewee::Util::Tcp.local_ip
        else
          # Not supported yet but these are some ideas
          # Try to figure out the remote IP address
          # ip -4 -o addr show  br0
          ip=Veewee::Util::Ssh.execute(@connection.uri.host,"ip -4 -o addr show br0",options ={ :user => "#{connection.uri.user}"}).stdout.split("inet ")[1].split("/").first
          return ip
        end
      end

    end
  end
end
