require 'veewee/builder/core/builder'

module Veewee
  module Builder
    module Kvm
      class Builder < Veewee::Builder::Core::Builder

        def old_build(build_options={})

          defaults= {  "force" => false, "nogui" => false }
          options=defaults.merge(build_options)

          if @definition.nil?
            abort("This definition could not be loaded")
          end

          if exists? || vol_exists?
            if options["force"]==true
              if running?
                destroy_vm
              end
              destroy
            else
              puts "Machine and/or volume already exists, use the force flag"
            end

          end
          assemble

          #Starting machine
          start_vm

          #waiting for it to boot
          puts "Waiting for the machine to boot"
          sleep @definition.boot_wait.to_i

          vnc_port=@connection.servers.all(:name => "#{@box_name}").first.vnc_port

          unless @connection.uri.ssh_enabled?
            ssh_tunnel_start([{:local_port => 5908, :remote_port => vnc_port.to_i , :ip => "127.0.0.1"}])
          end

          # Sending keystrokes
          @web_ip_address=web_ip_address
          send_sequence(@definition.boot_cmd_sequence)

          sleep 120 #Sleep 2 minutes to make arpwatch flush to wait for the ssh, otherwise we will have no ip

          # handle_kickstart

          transfer_buildinfo_file

          handle_postinstall

          ssh_tunnel_stop
          # Wait for web request
          # Do ssh stuff

        end
        
      end #End Class
    end # End Module
  end # End Module
end # End Module