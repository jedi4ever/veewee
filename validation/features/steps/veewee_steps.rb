# http://stackoverflow.com/questions/216202/why-does-an-ssh-remote-command-get-fewer-environment-variables-then-when-run-manu

Given /^a veeweebox was build$/ do
  @environment=Veewee::Environment.new()
  @provider_name=ENV['VEEWEE_PROVIDER']
  @definition_name=ENV['VEEWEE_BOXNAME']
  @box_name=ENV['VEEWEE_BOXNAME']
  @box=@environment.providers[@provider_name].get_box(@box_name)
end

When /^I run "([^\"]*)" over ssh$/ do |command|
  @sshresult=@box.ssh(command)
end

Then /^I should see the provided username in the output$/ do
  @sshresult.stdout.should =~ /#{ENV["VEEWEE_SSH_USER"]}/
end

Then /^I should see "([^\"]*)" in the output$/ do |string|
  @sshresult.stdout.should =~ /#{string}/
end

