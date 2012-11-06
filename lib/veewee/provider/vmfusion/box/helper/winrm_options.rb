module Veewee
  module Provider
    module Vmfusion
      module BoxCommand

        def winrm_options
          winrm_options={
            :user => definition.winrm_user,
            :pass => definition.winrm_password,
            :port => definition.winrm_host_port,
            :basic_auth_only => true,
            :timeout => definition.winrm_login_timeout.to_i,
            :operation_timeout => 600 # ten minutes
          }
          return winrm_options
        end

      end
    end
  end
end
