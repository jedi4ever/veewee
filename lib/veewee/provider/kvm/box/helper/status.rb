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
          !@connection.volumes.all(:name => "#{name}.img").nil?
        end

        def exists_vm?
          !@connection.servers.all(:name => name).nil?
        end

      end # End Module
    end # End Module
  end # End Module
end # End Module
