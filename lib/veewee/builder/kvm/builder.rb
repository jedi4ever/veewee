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
        
        def build(definition_name,box_name,options)

          super(definition_name,box_name,options)

          # w00t, we have succesfully reach this point
          # so we let user know , the vm is ready to be exported

          definition=get_definition(definition_name)
          
          # If no box_name was given, let's give the box the same name as the definition
          if box_name.nil?
            box_name=definition_name
          end
          
          #box=get_box(box_name)

          #env.ui.info "#{box.name} was build succesfully. "
          #env.ui.info ""
          #env.ui.info "Now you can ssh into the machine (password:#{definition.ssh_password})"
          #env.ui.info "ssh #{definition.ssh_user}@#{box.ip_address} -p #{ssh_options(definition)[:port]}"
          #env.ui.info ""

        end
        
      end #End Class
    end # End Module
  end # End Module
end # End Module