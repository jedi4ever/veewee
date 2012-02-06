module Veewee
  module Provider
    module Kvm
      module BoxCommand
        def ip_address
          ip=@connection.servers.all(:name => "#{name}").first.addresses[:public]
          return ip.first unless ip.nil?
          return ip
        end

      end # End Module
    end # End Module
  end # End Module
end # End Module
