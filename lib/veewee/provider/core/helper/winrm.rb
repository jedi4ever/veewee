module Veewee
  module Provider
    module Core
      module Helper

        class WinrmResult
          attr_accessor :stdout
          attr_accessor :stderr
          attr_accessor :status

          def initialize(stdout,stderr,status)
            @stdout=stdout
            @stderr=stderr
            @status=status
          end
        end

        module Winrm

          require 'timeout'
          require 'log4r'
          require 'em-winrm'
          require 'highline'
          
          def winrm_up?(ip,options)
            @httpcli = HTTPClient.new(:agent_name => 'Ruby WinRM Client')
            @httpcli.receive_timeout = 10
            @httpcli.set_auth(nil, options[:user], options[:pass])
            @httpcli.get("http://#{ip}:#{options[:port]}/wsman")
            return true
          rescue HTTPClient::ReceiveTimeoutError
            return false
          end

          def when_winrm_login_works(ip="127.0.0.1", options = {}, &block)

            options=winrm_options.merge(options.merge({:operation_timeout => 5}))

            env.ui.info  "Waiting for winrm login on #{ip} with user #{options[:user]} to windows on port => #{options[:port]} to work, timeout=#{options[:timeout]} sec"


            begin
              Timeout::timeout(options[:timeout]) do
                connected=false
                while !connected do
                  begin
                    env.ui.info ".",{:new_line => false}
                    next if not winrm_up?(ip, options)
                    winrm_execute(ip,"hostname",options.merge({:progress => nil}))
                    env.ui.info "\n"
                    block.call(ip);
                    env.ui.info ""
                    return true
                  rescue Exception => e  
                    puts e.inspect
                    puts e.message  
                    puts e.backtrace.inspect  
                    sleep 5
                  end
                end
              end
            rescue Timeout::Error
              env.ui.error "Winrm timeout #{options[:timeout]} sec has been reached."
              exit -1
            rescue WinRM::WinRMHTTPTransportError => e
              if e.message =~ /401/
                env.ui.error "Unable to authenticate as '#{options[:user]}' with password '#{options[:pass]}'"
              else
                raise e
              end
            end
            return false
          end


          def winrm_transfer_file(host,filename,destination = '.' , options = {})
            options = winrm_options.merge(options.merge({:paranoid => false }))
            # when_winrm_login_works

            env.ui.info "FIXME: Transferring #{filename} to #{destination} "
            # print these out while uploading:
            env.ui.info ".",{:new_line => false}
            # t::SSH.start( host,options[:user],options )
            env.ui.info ""
          end

          def new_session(host,options)
            opts = winrm_options.merge(options)

            # create a session
            begin
              endpoint = "http://#{host}:#{opts[:port]}/wsman"
              client = ::WinRM::WinRMWebService.new(endpoint, :plaintext, opts)
              client.set_timeout(opts[:operation_timeout]) if opts[:operation_timeout] 
            rescue ::WinRM::WinRMAuthorizationError => error
              raise ::WinRM::WinRMAuthorizationError.new("#{error.message}@#{host}")
            end
            client
          end
          
          def winrm_execute(host,command, options = { :progress => "on"} )
            
            options = winrm_options.merge({:exitcode => "0"}.merge(options))
            stdout=""
            stderr=""
            status=-99999

            session = new_session(host, options)

            env.ui.info "Executing winrm command: #{command}" if options[:progress]
            
            remote_id = session.open_shell
            command_id = session.run_command(remote_id, command)
            output = session.get_command_output(remote_id, command_id) do |out,error|
              if out
                stdout += out 
                env.ui.info out,{:new_line => false} if options[:progress]
              end
              if error
                stderr += error
                env.ui.info error,{:new_line => false} if options[:progress]
              end
            end
            status = output[:exitcode]
            env.ui.info "ERROR: exit code #{exit_code}" if status > 0

            if (status.to_s != options[:exitcode] )
              if (options[:exitcode]=="*")
                #its a test so we don't need to worry
              else
                raise "Exitcode was not what we expected"
              end

            end

            return Veewee::Provider::Core::Helper::WinrmResult.new(stdout,stderr,status)

          end



        end #Class
      end #Module
    end #Module
  end #Module
end #Module
