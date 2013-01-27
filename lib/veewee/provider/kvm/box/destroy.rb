module Veewee
  module Provider
    module Kvm
      module BoxCommand
        # Destroy a vm
        def destroy(options={})
          unless exists_vm? or exists_volume?
            env.ui.error "Error:: You tried to destroy a non-existing box '#{name}'"
            raise Veewee::Error,"Error:: You tried to destroy a non-existing box '#{name}'"
          end

          self.poweroff if running?
          destroy_vm if exists_vm?

          vol_exists = exists_volume?
          env.logger.info "Volume exists?: #{vol_exists}"
          destroy_volume if vol_exists
        end

        def destroy_vm
          matched_servers=@connection.servers.all(:name => name)
          matched_servers.first.destroy() unless matched_servers.nil?
        end

        def destroy_volume
          @connection.volumes.all(:name => @volume_name).first.destroy
        end
      end # End Module

    end # End Module
  end # End Module
end # End Module
