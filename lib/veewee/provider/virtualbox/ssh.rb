module Veewee
  module Provider
    module Virtualbox
      def ssh(command)
        ssh_options={ 
          :user => @definition.ssh_user, 
          :port => @definition.ssh_host_port,
          :password => @definition.ssh_password,
          :timeout => @definition.ssh_login_timeout.to_i
        }
        result=Veewee::Util::Ssh.execute("localhost","#{command}",ssh_options)
        return result
      end
    end #Module
  end #Module
end #Module