module Veewee
  module Provider
    module Kvm
      module BoxCommand

        def ssh_options
          ssh_options={
            :user => definition.ssh_user,
            :port => 22,
            :password => definition.ssh_password,
            :timeout => definition.ssh_login_timeout.to_i
          }
          return ssh_options
        end

      end # End Module
    end # End Module
  end # End Module
end # End Module
