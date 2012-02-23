module Veewee
  module Provider
    module Kvm
      module BoxCommand

        def halt(options={})
          matched_servers=@connection.servers.all(:name => name)
          matched_servers.first.halt unless matched_servers.nil?
        end

        def stop(options={})
          matched_servers=@connection.servers.all(:name => name)
          matched_servers.first.stop unless matched_servers.nil?
        end

      end # End Module
    end # End Module
  end # End Module
end # End Module
