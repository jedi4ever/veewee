require 'socket'
require 'net/ssh'
require 'net/scp'

module Veewee
  module Provider
    module Core
      module Helper

        class SshResult < RuntimeError
          attr_accessor :stdout
          attr_accessor :stderr
          attr_accessor :status

          def initialize(stdout,stderr,status)
            @stdout=stdout
            @stderr=stderr
            @status=status
          end
        end

      end
    end
  end
end

module Veewee::Provider::Core::Helper::Ssh

  def build_ssh_options
    ssh_options={
      :user => definition.ssh_user,
      :port => 22,
      :password => definition.ssh_password,
      :timeout => definition.ssh_login_timeout.to_i
    }
    ssh_options[:keys] = ssh_key_to_a(definition.ssh_key) if definition.ssh_key
    return ssh_options
  end

  def ssh_options
    build_ssh_options
  end

  def ssh_key_to_a(ssh_key)
    case ssh_key
    when "" then []
    else Array(ssh_key)
    end
  end

  # nonblocking ssh connection check
  def tcp_test_ssh(hostname, port, timeout = 2)

    addr = Socket.getaddrinfo(hostname, nil)
    sockaddr = Socket.pack_sockaddr_in(port, addr[0][3])

    Socket.new(Socket.const_get(addr[0][0]), Socket::SOCK_STREAM, 0).tap do |socket|
      socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
      begin
        socket.connect_nonblock(sockaddr)

      rescue IO::WaitWritable
        if IO.select(nil, [socket], nil, timeout)
          begin
            result = socket.connect_nonblock(sockaddr)
            if result == 0
              socket.close
              return true
            end
          rescue Errno::EISCONN
            socket.close
            return true
          rescue
            socket.close
            return false
          end
        else
          socket.close
          return false
        end
      end
    end
    false
  end

  def when_ssh_login_works(ip="127.0.0.1", options = {  } , &block)
    defaults={ :port => '22', :timeout => 20000 }
    options=defaults.merge(options)

    timeout = options[:timeout]
    timeout = ENV['VEEWEE_TIMEOUT'].to_i unless ENV['VEEWEE_TIMEOUT'].nil?

    unless options[:mute]
      ui.info  "Waiting for ssh login on #{ip} with user #{options[:user]} to sshd on port => #{options[:port]} to work, timeout=#{timeout} sec"
    end

    run_hook(:before_ssh)

    begin
      Timeout::timeout(timeout) do
        connected=false
        while !connected do
          begin
            env.ui.info ".",{:new_line => false , :prefix => false} unless options[:mute]
            if
              tcp_test_ssh(ip, options[:port])
            then
              ssh_connection(ip, options, :timeout => timeout ) do |ssh|
                ui.info "\n", {:prefix => false} unless options[:mute]
                block.call(ip);
                return true
              end
            else
              sleep 5
            end
          rescue Net::SSH::Disconnect, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ECONNABORTED, Errno::ECONNRESET, Errno::ENETUNREACH, Errno::ETIMEDOUT
            sleep 5
          end
        end
      end
    rescue IOError
      ui.info "Received a disconnect; moving on"
      sleep 5
    rescue Timeout::Error
      raise Veewee::Error, "Ssh timeout #{timeout} sec has been reached."
    end
    ui.info ""
    return false
  end

  def ssh_transfer_file(host,filename,destination = '.' , options = {})

    ssh_connection( host, options ) do |ssh|
      ui.info "Transferring #{filename} to #{destination} "
      ssh.scp.upload!( filename, destination ) do |ch, name, sent, total|
        #   print "\r#{destination}: #{(sent.to_f * 100 / total.to_f).to_i}%"
        env.ui.info ".",{:new_line => false , :prefix => false}
      end
    end
    ui.info "", {:prefix => false}
  end


  def ssh_execute(host,command, options = { :progress => "on"} )
    defaults= { :port => "22", :exitcode => "0", :user => "root"}
    options=defaults.merge(options)
    pid=""
    stdin=command
    stdout=""
    stderr=""
    status=-99999

    unless options[:mute]
      ui.info "Executing command: #{command}"
    end

    ssh_connection( host, options ) do |ssh|

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
            ui.info(data, :new_line => false) unless options[:mute]
          end

          # "on_extended_data" is called when the process writes something to stderr
          # NOTE: When requesting a pty (ch.request_pty), everything goes to stdout
          ch.on_extended_data do |c, type, data|
            stderr+=data
            ui.info(data, :new_line => false) unless options[:mute]
          end

          #exit code
          #http://groups.google.com/group/comp.lang.ruby/browse_thread/thread/a806b0f5dae4e1e2
          channel.on_request("exit-status") do |ch, data|
            exit_code = data.read_long
            status=exit_code
            if exit_code > 0
              ui.info "ERROR: exit code #{exit_code}" unless options[:mute]
            else
              #ui.info "Successfully executed"
            end
          end

          channel.on_request("exit-signal") do |ch, data|
            ui.info "SIGNAL: #{data.read_long}" unless options[:mute]
          end

          ch.on_close {
            #ui.info "done!"
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
        raise Veewee::Provider::Core::Helper::SshResult.new(stdout,stderr,status), "Exitcode was not what we expected"
      end

    end

    return Veewee::Provider::Core::Helper::SshResult.new(stdout,stderr,status)
  end

  def ssh_connection(host, options, defaults={}, &block)
    options=defaults.merge(options)
    options={
      :auth_methods => %w[ password publickey keyboard-interactive ],
      :paranoid => false
    }.merge(options)
    options=Hash[ options.select { |key, value| Net::SSH::VALID_OPTIONS.include?(key) } ]
    Net::SSH.start( host, options[:user], options ) do |ssh|
      yield ssh
    end
  end

end
