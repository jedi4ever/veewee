module Veewee
  module Provider
    module Core
      module Helper

        class SshResult
          attr_accessor :stdout
          attr_accessor :stderr
          attr_accessor :status

          def initialize(stdout,stderr,status)
            @stdout=stdout
            @stderr=stderr
            @status=status
          end
        end

        module Ssh

          require 'net/ssh'
          require 'net/scp'

          def when_ssh_login_works(ip="127.0.0.1", options = {  } , &block)

            defaults={ :port => '22', :timeout => 20000 }

            options=defaults.merge(options)

            env.ui.info  "Waiting for ssh login on #{ip} with user #{options[:user]} to sshd on port => #{options[:port]} to work, timeout=#{options[:timeout]} sec"

            begin
              Timeout::timeout(options[:timeout]) do
                connected=false
                while !connected do
                  begin
                    env.ui.info ".",{:new_line => false}
                    Net::SSH.start(ip, options[:user], { :port => options[:port] , :password => options[:password], :paranoid => false , :timeout => options[:timeout] }) do |ssh|
                      env.ui.info "\n"

                      block.call(ip);
                      env.ui.info ""
                      return true
                    end
                  rescue Net::SSH::Disconnect,Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ECONNABORTED, Errno::ECONNRESET, Errno::ENETUNREACH,Errno::ETIMEDOUT, Errno::ENETUNREACH
                    sleep 5
                  end
                end
              end
            rescue Timeout::Error
              env.ui.error "Ssh timeout #{options[:timeout]} min has been reached."
              exit -1
            end
            env.ui.info ""
            return false
          end


          def ssh_transfer_file(host,filename,destination = '.' , options = {})

            defaults={ :paranoid => false }
            options=defaults.merge(options)

            Net::SSH.start( host,options[:user],options ) do |ssh|
              env.ui.info "Transferring #{filename} to #{destination} "
              ssh.scp.upload!( filename, destination ) do |ch, name, sent, total|
                #   print "\r#{destination}: #{(sent.to_f * 100 / total.to_f).to_i}%"
                env.ui.info ".",{:new_line => false}

              end
            end
            env.ui.info ""
          end


          def ssh_execute(host,command, options = { :progress => "on"} )
            defaults= { :port => "22", :exitcode => "0", :user => "root"}
            options=defaults.merge(options)
            pid=""
            stdin=command
            stdout=""
            stderr=""
            status=-99999

            env.ui.info "Executing command: #{command}"

            Net::SSH.start(host, options[:user], { :port => options[:port], :password => options[:password], :paranoid => false }) do |ssh|

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
                    stdout+=data

                    env.ui.info data,{:new_line => false}

                  end

                  # "on_extended_data" is called when the process writes something to stderr
                  ch.on_extended_data do |c, type, data|
                    stderr+=data

                    env.ui.info data,{:new_line => false}

                  end

                  #exit code
                  #http://groups.google.com/group/comp.lang.ruby/browse_thread/thread/a806b0f5dae4e1e2
                  channel.on_request("exit-status") do |ch, data|
                    exit_code = data.read_long
                    status=exit_code
                    if exit_code > 0
                      env.ui.info "ERROR: exit code #{exit_code}"
                    else
                      #env.ui.info "Successfully executed"
                    end
                  end

                  channel.on_request("exit-signal") do |ch, data|
                    env.ui.info "SIGNAL: #{data.read_long}"
                  end

                  ch.on_close {
                    #env.ui.info "done!"
                  }
                  #status=ch.exec "echo $?"
                end
              end
              channel.wait
            end


            if (status.to_s != options[:exitcode] )
              if (options[:exitcode]=="*")
                #its a test so we don't need to worry
              else
                raise "Exitcode was not what we expected"
              end

            end

            return Veewee::Provider::Core::Helper::SshResult.new(stdout,stderr,status)

          end



        end #Class
      end #Module
    end #Module
  end #Module
end #Module
