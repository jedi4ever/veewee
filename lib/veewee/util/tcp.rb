require 'socket'
require 'timeout'

module Veewee
  module Util
    class Tcp
      def self.is_port_open?(ip, port)
        begin
          Timeout::timeout(1) do
            begin
              s = TCPSocket.new(ip, port)
              s.close
              return true
            rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
              return false
            end
          end
        rescue Timeout::Error
        end

        return false
      end

      #we need to try the actual login because vbox gives us a connect
      #after the machine boots
      def self.execute_when_tcp_available(ip="localhost", options = { } , &block)

        defaults={ :port => 22, :timeout => 2 , :pollrate => 5}

        options=defaults.merge(options)

        begin
          Timeout::timeout(options[:timeout]) do
            connected=false
            while !connected do
              begin
                puts "trying connection"
                s = TCPSocket.new(ip, options[:port])
                s.close
                block.call(ip);
                return true
              rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
                sleep options[:pollrate]
              end
            end
          end
        rescue Timeout::Error
          raise 'timeout connecting to port'
        end

        return false
      end

      def self.local_ip
        orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily

        UDPSocket.open do |s|
          s.connect '64.233.187.99', 1
          s.addr.last
        end
      ensure
        Socket.do_not_reverse_lookup = orig
      end
    end #Class
  end #Module
end #Module
