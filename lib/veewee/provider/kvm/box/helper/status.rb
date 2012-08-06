module Veewee
  module Provider
    module Kvm
      module BoxCommand
        def running?
          if exists_vm?
            @connection.servers.all(:name => name).first.ready?
          else
            false
          end
        end

        def exists?
          exists_volume? || exists_vm?
        end

        def exists_volume?
          @connection.list_volumes.find { |v| v[:name] == "#{name}.img" }
        end

        def exists_vm?
          @connection.list_domains.find { |d| d[:name] == name }
        end

      end # End Module
    end # End Module
  end # End Module
end # End Module
