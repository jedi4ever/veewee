module Veewee
  module Provider
    module Kvm
      module BoxCommand

        def poweroff(options={})
          matched_servers=@connection.servers.all(:name => name)
          matched_servers.first.stop unless matched_servers.nil?
        end

      end # End Module
    end # End Module
  end # End Module
end # End Module
