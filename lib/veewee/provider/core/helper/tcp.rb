require 'socket'
require 'timeout'

module Veewee
  module Provider
    module Core
      module Helper
        module Tcp

          def is_tcp_port_open?(ip, port)
            begin
              Timeout::timeout(1) do
                begin
                  s = TCPSocket.new(ip, port)
                  s.close
                  return true
                rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH,Errno::ENETDOWN
                  return false
                end
              end
            rescue Timeout::Error
            end

            return false
          end

          # This tries to guess a local free tcp port 
          def guess_free_port(min_port,max_port)
            ui.info "Received port hint - #{min_port}"

            if definition.force_ssh_port
              return min_port
            end

            guessed_port=nil

            for port in (min_port..max_port)
              unless is_tcp_port_open?(get_local_ip, port)
                guessed_port=port
                break
              end
            end

            if guessed_port.nil?
              ui.error "No free port available: tried #{min_port}..#{max_port}"
              raise Veewee::Error, "No free port available: tried #{min_port}..#{max_port}"
            else
              ui.info "Found port #{guessed_port} available"
            end

            return guessed_port
          end

          def execute_when_tcp_available(ip="127.0.0.1", options = { } , &block)

            defaults={ :port => 22, :timeout => 2 , :pollrate => 5}

            options=defaults.merge(options)
            timeout=options[:timeout]
            timeout=ENV['VEEWEE_TIMEOUT'].to_i unless ENV['VEEWEE_TIMEOUT'].nil?

            begin
              Timeout::timeout(timeout) do
                connected=false
                while !connected do
                  begin
                    ui.info "trying connection"
                    s = TCPSocket.new(ip, options[:port])
                    s.close
                    block.call(ip);
                    return true
                  rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH,Errno::ENETDOWN
                    sleep options[:pollrate]
                  end
                end
              end
            rescue Timeout::Error
              raise "Timeout connecting to TCP port {options[:port]} exceeded #{timeout} secs."
            end

            return false
          end

          def host_ip_as_seen_by_guest
            get_local_ip
          end

          def get_local_ip
            orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily

            UDPSocket.open do |s|
              s.connect '64.233.187.99', 1
              s.addr.last
            end
          ensure
            Socket.do_not_reverse_lookup = orig
          end
        end #Module
      end #Module
    end #Module
  end #Module
end #Module
