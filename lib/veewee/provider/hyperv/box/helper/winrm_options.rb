module Veewee
  module Provider
    module Hyerpv
      module BoxCommand

        def winrm_options
          port=definition.winrm_host_port

          winrm_options={
              :user => definition.winrm_user,
              :pass => definition.winrm_password,
              :port => port,
              #            :port => (port.to_i+1).to_s, # debug, by running charles with a reverse proxy
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
