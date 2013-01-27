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
          !@connection.list_volumes(:name => @volume_name).first.empty?
        end

        def exists_vm?
          begin
            @connection.list_domains(:name => name)
          rescue Libvirt::RetrieveError
            false
          end
        end

      end # End Module
    end # End Module
  end # End Module
end # End Module
