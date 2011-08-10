# http://stackoverflow.com/questions/216202/why-does-an-ssh-remote-command-get-fewer-environment-variables-then-when-run-manu

Given /^I have no public keys set$/ do
  @auth_methods = %w(password)
end

Then /^I can ssh to "([^\"]*)" with the following credentials:$/ do |host, table|
  @auth_methods ||= %w(publickey password)
  
  credentials = table.hashes
  credentials.each do |creds|
    lambda {
	    Net::SSH.start(host, creds["username"], :password => creds["password"], :auth_methods => @auth_methods)
    }.should_not raise_error(Net::SSH::AuthenticationFailed)
  end
end

Then /^I can ssh to the following hosts with these credentials:$/ do |table|
  @keys ||= []
  @auth_methods ||= %w(password)
  session_details = table.hashes

  session_details.each do |session|
    # initialize a list of keys and auth methods for just this session, as 
    # session can have session-specific keys mixed with global keys
    session_keys = Array.new(@keys)
    session_auth_methods = Array.new(@auth_methods) 

    # you can pass in a keyfile in the session details, so we need to 
    if session["keyfile"]
      session_keys << session["keyfile"]
      session_auth_methods << "publickey"
    end
    
    lambda {
	    Net::SSH.start(session["hostname"], session["username"], :password => session["password"],
                                                               :auth_methods => session_auth_methods,
                                                               :keys => session_keys)
    }.should_not raise_error(Net::SSH::AuthenticationFailed)
  end
end

Given /^I have the following public keys:$/ do |table|
  @keys = []
  public_key_paths = table.hashes

  public_key_paths.each do |key|
    File.exist?(key["keyfile"]).should be_true
    @keys << key["keyfile"]
  end

  @auth_methods ||= %w(password)
  @auth_methods << "publickey"
end

When /^I ssh to "([^\"]*)" with the following credentials:$/ do |hostname, table|
  @keys = []
  @auth_methods ||= %w(password)
  session = table.hashes.first
  session_keys = Array.new(@keys)
  session_auth_methods = Array.new(@auth_methods) 
  if session["keyfile"]
    session_keys << session["keyfile"]
    session_auth_methods << "publickey"
  end
  session_port = ENV['VEEWEE_SSH_PORT'] || 7222
  if session["port"]
     session_port=session["port"]  
  end
  

  lambda {
         # This is the list of authorization methods to try. It defaults to “publickey”, “hostbased”, “password”, and “keyboard-interactive”. (These are also the only authorization methods that are supported.) If
         # http://net-ssh.rubyforge.org/ssh/v1/chapter-2.html
    key_auth_tried = false
    ssh_options = {:password => session["password"], :auth_methods => session_auth_methods, :port => session_port, :keys => session_keys}
    # ssh_options[:verbose] => :debug
    begin
      print "."
      @connection = Net::SSH.start(session["hostname"], session["username"], ssh_options)
    rescue Net::SSH::AuthenticationFailed
      ssh_options[:keys] = Array.new([File.join(File.dirname(__FILE__),'./../../vagrant')])
      ssh_options.delete(:password)
      ssh_options[:auth_methods] = ['publickey']
      if key_auth_tried
         raise
      else
         key_auth_tried = true
        retry
      end
    rescue Net::SSH::Disconnect, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ECONNABORTED, Errno::ECONNRESET, Errno::ENETUNREACH
      sleep 5
    end
  }.should_not raise_error
end

#
When /^I run "([^\"]*)"$/ do |command| 
  @stdout=nil
  @stderr=nil
  @status=-9999
  channel = @connection.open_channel do |ch|
	  ch.request_pty do |ch, success|
      if success
#		    puts "pty successfully obtained"
		  else
#		    puts "could not obtain pty"
		  end
	  end
    ch.exec "#{command}" do |ch, success|
       raise "could not execute command" unless success

       # "on_data" is called when the process writes something to stdout
      ch.on_data do |c, data|
        if @stdout.nil?
          @stdout=data
        else  
          @stdout+=data
        end
      end

      # "on_extended_data" is called when the process writes something to stderr
      ch.on_extended_data do |c, type, data|
          if @stderr.nil?
            @stderr=data
          else  
            @stderr+=data
          end
      end
      
      #exit code
      #http://groups.google.com/group/comp.lang.ruby/browse_thread/thread/a806b0f5dae4e1e2
      channel.on_request("exit-status") do |ch, data|
        exit_code = data.read_long
        @status=exit_code
      end
      
      channel.on_request("exit-signal") do |ch, data|
        puts "SIGNAL: #{data.read_long}"
      end

      ch.on_close {
        puts "done!"
      }
    end
  end
  channel.wait
  if !@stdout.nil?
    if @output.nil?
      @output=""
    end
    @output=@output+@stdout
  end
  if !@stderr.nil?

    if @output.nil?
      @output=""
    end
    @output=@output+@stderr
  end
  puts @output

	#@output = @connection.exec!(command)

end

Then /^I should see "([^\"]*)" in the output$/ do |string|
  @output.should =~ /#{string}/
end

