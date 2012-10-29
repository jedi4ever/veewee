module Veewee
  module Provider
    module Kvm
      module BoxCommand
        # Destroy a vm
        def destroy(options={})
          if @connection.servers.all(:name => name).nil?
            env.ui.error "Error:: You tried to destroy a non-existing box '#{name}'"
            raise Veewee::Error,"Error:: You tried to destroy a non-existing box '#{name}'"
          end

          self.poweroff if running?
          destroy_vm if exists_vm?

          vol_exists=!@connection.volumes.all(:name => "#{name}.img").nil?
          env.logger.info "Volume exists? : #{vol_exists}"
          destroy_volume if exists_volume?
        end

        def destroy_vm
          matched_servers=@connection.servers.all(:name => name)
          matched_servers.first.destroy() unless matched_servers.nil?
        end

        def destroy_volume
          vol=@connection.volumes.all(:name => "#{name}.img").first
          vol.destroy
        end
      end # End Module

    end # End Module
  end # End Module
end # End Module
