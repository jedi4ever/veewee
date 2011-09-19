require 'veewee/builder/core/builder'

module Veewee
  module Builder
    module Kvm
      class Builder < Veewee::Builder::Core::Builder

        # Translate the definition ssh options to ssh options that can be passed to Net::Ssh calls
        # We expect plain ssh for a connection

        def ssh_options(definition)
          ssh_options={
            :user => definition.ssh_user,
            :port => 22,
            :password => definition.ssh_password,
            :timeout => definition.ssh_login_timeout.to_i
          }
          return ssh_options
        end
        
      end #End Class
    end # End Module
  end # End Module
end # End Module