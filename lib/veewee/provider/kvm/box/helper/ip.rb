module Veewee
  module Provider
    module Kvm
      module BoxCommand
        def ip_address
          ip=@connection.servers.all(:name => "#{name}").first.public_ip_address
          return [*ip].first unless ip.nil?
          return ip
        end

      end # End Module
    end # End Module
  end # End Module
end # End Module
