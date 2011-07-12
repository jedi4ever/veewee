module Veewee
  class Ssh

    def self.when_ssh_login_works(ip="localhost", options = {  } , &block)

      defaults={ :port => '22', :timeout => 200 , :user => 'vagrant', :password => 'vagrant'}

      options=defaults.merge(options)

      puts
      puts "Waiting for ssh login with user #{options[:user]} to sshd on port => #{options[:port]} to work"

      begin
        Timeout::timeout(options[:timeout]) do
          connected=false
          @key_auth_tried = false
          ssh_options = { :port => options[:port] , :password => options[:password], :paranoid => false, :timeout => options[:timeout]  }
          while !connected do
            begin
              print "."
              Net::SSH.start(ip, options[:user], ssh_options) do |ssh|
                block.call(ip);
                puts ""
                return true
              end
            rescue Net::SSH::AuthenticationFailed
              options[:keys] = File.join(File.dirname(__FILE__),'./../../validation/vagrant')
              options.delete(:password)
              ssh_options = options
              if @key_auth_tried
                 raise
              else
                 @key_auth_tried = true
                retry
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


    def self.transfer_file(host,filename,destination = '.' , options = {})
      
      Net::SSH.start( host,options[:user],options ) do |ssh|
        puts "Transferring #{filename} to #{destination} "
        ssh.scp.upload!( filename, destination ) do |ch, name, sent, total|
       #   print "\r#{destination}: #{(sent.to_f * 100 / total.to_f).to_i}%"
          print "."

        end
      end 
      puts
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

    def self.execute(host,command, options = { :progress => "on"} )
      defaults= { :port => "22", :exitcode => "0", :user => "root"}
      options=defaults.merge(options)
      @pid=""
      @stdin=command
      @stdout=""
      @stderr=""
      @status=-99999

      puts "Executing command: #{command}"

      @key_auth_tried = false
      ssh_options = { :port => options[:port], :password => options[:password], :paranoid => false}
      # ssh_options[:verbose] => :debug
      begin
        Net::SSH.start(host, options[:user], ssh_options) do |ssh|

            # open a new channel and configure a minimal set of callbacks, then run
            # the event loop until the channel finishes (closes)
            channel = ssh.open_channel do |ch|

              #request pty for sudo stuff and so
              ch.request_pty do |ch, success|
                  raise "Error requesting pty" unless success
              end


              ch.exec "#{command}" do |ch, success|
                raise "could not execute command" unless success



                # "on_data" is called when the process writes something to stdout
                ch.on_data do |c, data|
                  @stdout+=data

                    print data

                end

                # "on_extended_data" is called when the process writes something to stderr
                ch.on_extended_data do |c, type, data|
                  @stderr+=data

                    print data

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
      rescue Net::SSH::AuthenticationFailed
        ssh_options[:keys] = Array.new([File.join(File.dirname(__FILE__),'./../../validation/vagrant')])
        ssh_options.delete(:password)
        ssh_options[:auth_methods] = ['publickey']
        if @key_auth_tried
           raise
        else
           @key_auth_tried = true
          retry
        end
      rescue Net::SSH::Disconnect, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ECONNABORTED, Errno::ECONNRESET, Errno::ENETUNREACH
        sleep 1
      end
  
      if (@status.to_s != options[:exitcode] )
        if (options[:exitcode]=="*")
          #its a test so we don't need to worry
        else
          raise "Exitcode was not what we expected"
        end

      end

    end



  end #Class
end #Module
