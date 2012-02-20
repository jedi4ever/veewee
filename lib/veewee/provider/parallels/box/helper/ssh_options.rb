module Veewee
  module Provider
    module Parallels
      module BoxCommand

        # Translate the definition ssh options to ssh options that can be passed to Net::Ssh calls
        def ssh_options
          ssh_options={
            :user => definition.ssh_user,
            :port => 22,
            :password => definition.ssh_password,
            :timeout => definition.ssh_login_timeout.to_i
          }
          return ssh_options
        end

      end
    end
  end
end
