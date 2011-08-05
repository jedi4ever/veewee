  require 'net/ssh/multi'
      
  module Veewee
    module Builder
      module Kvm

        def ssh_tunnel_start
          #ssh_options={ :keys => [ vm.private_key ], :paranoid => false, :keys_only => true}
        
            ssh_options={ :paranoid => false}
            host=@connection.uri.host
            user=@connection.uri.user
        
            @ssh_tunnel=Net::SSH.start(host, user, ssh_options)
            forwardings=[ { }]
            forwardings.each do |forwarding|
                begin
                  puts "Forwarding remote port #{forwarding.remote} from #{vm.name} to local port #{forwarding.local}"
                  ssh.forward.local(forwarding.local, private_ip_address,forwarding.remote)
                rescue Errno::EACCES
                  puts "  Error - Access denied to forward remote port #{forwarding.remote} from #{vm.name} to local port #{forwarding.local}"
                end
              end
            
            
        end
        
        def ssh_tunnel_stop
          @ssh_tunnel.close
        end
        
      end
    end
  end