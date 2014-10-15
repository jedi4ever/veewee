module Veewee
  module Provider
    module Kvm
      module BoxCommand

        def up(options={})
          matched_servers=@connection.servers.all(:name => name)
          matched_servers.first.start unless matched_servers.nil?
        rescue Libvirt::Error => e
          warn "
Libvirt Error! Make sure your user has permissions to run anything.
"
          raise e
        end

      end # End Module
    end # End Module
  end # End Module
end # End Module
