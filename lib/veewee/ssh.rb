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
    
    #we need to try the actual login because vbox gives us a connect
    #after the machine boots
    def execute_when_tcp_available(ip="localhost", options = { } , &block)

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
    
    def self.execute(command, options = { :progress => "off"} )
       defaults= { :port => "22", :exitcode => "0", :user => "root"}
         options=defaults.merge(options)
         @pid=""
         @stdin=command
         @stdout=""
         @stderr=""
         @status=-99999

         print reset
          80.times { print "-"}
         puts ""
         print blue
         puts "Executing command: "
         print reset
         puts "# #{command}"
         print reset

       if options[:host]
         #this is a remote machine so we should ssh into the box
         configfile="#{ENV['VM_STATE']}/.ssh/ssh_config.systr"

         Net::SSH.start(options[:host], options[:user], { :port => options[:port], :password => options[:password], :paranoid => false }) do |ssh|

           # open a new channel and configure a minimal set of callbacks, then run
           # the event loop until the channel finishes (closes)
           channel = ssh.open_channel do |ch|
             ch.exec "#{command}" do |ch, success|
               raise "could not execute command" unless success

               # "on_data" is called when the process writes something to stdout
               ch.on_data do |c, data|
                 @stdout+=data
                 if options[:progress]=="on"
                   puts data
                 end
               end

               # "on_extended_data" is called when the process writes something to stderr
               ch.on_extended_data do |c, type, data|
                 @stderr+=data
                 if options[:progress]=="on"
                   puts data
                 end
               end

               #exit code
               #http://groups.google.com/group/comp.lang.ruby/browse_thread/thread/a806b0f5dae4e1e2
               channel.on_request("exit-status") do |ch, data|
                 exit_code = data.read_long
                 @status=exit_code
                 if exit_code > 0
                   puts "ERROR: exit code #{exit_code}"
                 else
                   #puts "Successfully executed"
                 end
               end

               channel.on_request("exit-signal") do |ch, data|
                 puts "SIGNAL: #{data.read_long}"
               end

               ch.on_close {
                 #puts "done!"
                 }
               #status=ch.exec "echo $?"
             end
           end
                channel.wait
                 end
               else
                 status = Open4::popen4(command) do |pid, stdin, stdout, stderr|
                   @pid=pid
                   @stdin=command
                   @stdout=""
                   @stderr=""

                   while(line=stdout.gets)
                     @stdout+=line
                     if options[:progress]=="on"
                       puts line
                     end

                   end

                   while(line=stderr.gets)
                     @stderr+=line
                     if options[:progress]=="on"
                       puts line
                     end
                   end

                   unless @stdout.nil?
                     @stdout=@stdout.strip
                   end
                   unless @stderr.nil?
                     @stderr=@stderr.strip
                   end

                 end
                 @status=status.to_i
               end

               result=ShellutilResult.new(@pid,@stdin,@stdout,@stderr,@status)

           #coloring http://www.ruby-forum.com/topic/141589
               print blue
               puts "Result:"
               print reset
               if (@status!=0)
                 print red
               else
                 print green
               end
               puts result.stdout.indent(2)
               puts result.stderr.indent(2)
               print reset


               if (@status.to_s != options[:exitcode] )
                 if (options[:exitcode]=="*")
                   #its a test so we don't need to worry
                 else
                   raise "Exitcode was not what we expected"
                 end

               end

               return result
             end
    
    

end
end
