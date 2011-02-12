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
  session_port=22
  if session["port"]
     session_port=session["port"]  
  end
  

  lambda {
    @connection = Net::SSH.start(hostname, session["username"], :password => session["password"], 
                                                                :auth_methods => session_auth_methods,
# This is the list of authorization methods to try. It defaults to “publickey”, “hostbased”, “password”, and “keyboard-interactive”. (These are also the only authorization methods that are supported.) If 
#http://net-ssh.rubyforge.org/ssh/v1/chapter-2.html
                                                                :port => session_port,
                                                                :keys => session_keys)
#                                                                :keys => session_keys,:verbose => :debug)
  }.should_not raise_error
end

When /^I run "([^\"]*)"$/ do |command| 
#  @connection.open_channel do |ch|
#
	  #ch.request_pty do |ch, success|
		#raise "Error requesting pty" unless success
	  #end
	  #@output = ch.exec(command)
  #end
	  @output = @connection.exec!(command)

end

Then /^I should see "([^\"]*)" in the output$/ do |string|
  @output.should =~ /#{string}/
end

