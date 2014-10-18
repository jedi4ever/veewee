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

          def build_winrm_options
            {
              :user => definition.winrm_user,
              :pass => definition.winrm_password,
              :port => definition.winrm_host_port,
              :basic_auth_only => true,
              :timeout => definition.winrm_login_timeout.to_i,
              :operation_timeout => 600 # ten minutes
            }
          end

          def winrm_options
            build_winrm_options
          end

          def winrm_up?(ip,options)
            begin
              if not @winrm_up
                @httpcli = HTTPClient.new(:agent_name => 'Ruby WinRM Client')
                @httpcli.receive_timeout = 10
                @httpcli.set_auth(nil, options[:user], options[:pass])
                @httpcli.get("http://#{ip}:#{options[:port]}/wsman")
                @winrm_up = true
              end
            rescue HTTPClient::ReceiveTimeoutError,HTTPClient::ConnectTimeoutError
              @winrm_up = false
            end
            @winrm_up
          end


          def when_winrm_login_works(ip="127.0.0.1", options = {}, &block)

            #options=winrm_options.merge(options.merge({:operation_timeout => 5}))
            options=winrm_options.merge(options)
            @login_works ||= {}
            begin
              Timeout::timeout(options[:timeout]) do
                if @login_works[ip]
                  block.call(ip);
                else
                  env.ui.info  "Waiting for winrm login on #{ip} with user #{options[:user]} to windows on port => #{options[:port]} to work, timeout=#{options[:timeout]} sec"
                  until @connected do
                    begin
                      sleep 1
                      env.ui.info ".",{:new_line => false}
                      next if not winrm_up?(ip, options)
                      winrm_execute(ip,"hostname",options.merge({:progress => nil}))
                      @login_works[ip]=true
                      env.ui.info "\n"
                      block.call(ip);
                      env.ui.info ""
                      sleep 1
                      @connected = true
                      return true
                    rescue Exception => e
                      @winrm_up = false
                      next if e.message =~ /401/ # 2012 gives 401 errors
                      puts e.inspect
                      puts e.message
                      puts e.backtrace.inspect
                      sleep 5
                    end
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
              if opts[:operation_timeout]
                client.set_timeout(opts[:operation_timeout])
              end
            rescue ::WinRM::WinRMAuthorizationError => error
              raise ::WinRM::WinRMAuthorizationError.new("#{error.message}@#{host}")
            end
            client
          end

          def winrm_execute(host,command, options)

            options = winrm_options.merge( # global default
                                          { # function defaults
                                            :exitcode => "0",
                                            :progress => "on"
                                          }.merge(
                                            options # calling override
                                          ))
                                          stdout=""
                                          stderr=""
                                          status=-99999

                                          @session ||= new_session(host, options)

                                          env.ui.info "Executing winrm command: #{command}" if options[:progress]

                                          @remote_id ||= @session.open_shell
                                          command_id = @session.run_command(@remote_id, command)
                                          output = @session.get_command_output(@remote_id, command_id) do |out,error|
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
                                          @session.close_shell(@remote_id)
                                          @remote_id = nil
                                          # env.ui.info "EXITCODE: #{status}" if status > 0
                                          # @session.unbind
                                          # FIXME: May want to look for a list of possible exitcodes
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
