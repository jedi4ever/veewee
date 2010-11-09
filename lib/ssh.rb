def when_ssh_login_works(sshparams= {},&block)
      Shellutil.execute_when_ssh_available(ip="localhost", sshparams) do
              yield
                end
end


def execute_when_ssh_available(ip="localhost", options = {  } , &block)

          defaults={ :port => '22', :timeout => 2 , :gw_machine => '' , :gw_port => '22' , :gw_user => 'root' , :user => 'root', :password => ''}

          print "sshing to => #{options[:port]}"

          options=defaults.merge(options)
          configfile="#{ENV['VM_STATE']}/.ssh/ssh_config.systr"

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

def self.execute(command, options = { :progress => "off"} )

        Net::SSH.start(options[:host], options[:user], { :port => options[:port], :password => options[:password], :paranoid => false }) do |ssh|
        end
end
