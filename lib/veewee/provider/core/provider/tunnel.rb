#require 'net/ssh/multi'

module Veewee
  module Provider
    module Core
      module ProviderCommand


      def ssh_tunnel_start(forwardings)
        #ssh_options={ :keys => [ vm.private_key ], :paranoid => false, :keys_only => true}

        ssh_options={ :paranoid => false}
        host=@connection.uri.host
        user=@connection.uri.user

        ui.info "Enabling tunneling"
        @forward_threads=Array.new
        @forward_threads<< Thread.new {
          Net::SSH.start(host, user, ssh_options) do |ssh_session|
          forwardings.each do |forwarding|
            begin
              ui.info "Forwarding remote port #{forwarding[:remote_port]} from #{box_name} to local port #{forwarding[:local_port]}"
              ui.info host
              ui.info user
              ui.info ""
              ssh_session.forward.local(forwarding[:local_port], "127.0.0.1",forwarding[:remote_port])
            rescue Errno::EACCES
              ui.info "  Error - Access denied to forward remote port #{forwarding[:remote_port]} from #{name} to local port #{forwarding[:local_port]}"
            end
          end
          ssh_session.loop {true}
          end
        }
        ui.info @forward_threads.first.status
        @forward_threads.first.run
        ui.info @forward_threads.first.status

      end

      def ssh_tunnel_stop
        Thread.kill(@forward_threads.first)
      end
    end
    end
  end
end
