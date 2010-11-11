module Veewee
  class Ssh

      def self.when_ssh_login_works(ip="localhost", options = {  } , &block)

          defaults={ :port => '22', :timeout => 200 , :user => 'vagrant', :password => 'vagrant'}

          print "sshing to => #{options[:port]}"

          options=defaults.merge(options)

         begin
               Timeout::timeout(options[:timeout]) do
                     connected=false
                     while !connected do
                     begin
                           print "."
                           Net::SSH.start(ip, options[:user], { :port => options[:port] , :password => options[:password], :paranoid => false, :timeout => options[:timeout]  }) do |ssh|
                                 block.call(ip);
                             puts ""
                            return true
                           end
                           rescue Net::SSH::Disconnect,Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ECONNABORTED, Errno::ECONNRESET, Errno::ENETUNREACH
                           sleep 5
                           end
                     end
               end
               rescue Timeout::Error
                raise 'ssh timeout'
               end
               puts ""
    return false
end

end
end
