require 'winrm'
endpoint = 'http://localhost:5985/wsman'
winrm=WinRM::WinRMWebService.new(endpoint, :plaintext, :user => 'Administrator', :pass => 'vagrant', :basic_auth_only => true)
winrm.cmd('ifconfig /all') do |stdout, stderr|
  STDOUT.print stdout
  STDERR.print stderr
end
#winrm.open_shell
