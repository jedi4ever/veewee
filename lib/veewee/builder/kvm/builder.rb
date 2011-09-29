require 'veewee/builder/core/builder'

module Veewee
  module Builder
    module Kvm
      class Builder < Veewee::Builder::Core::Builder

        # Translate the definition ssh options to ssh options that can be passed to Net::Ssh calls
        # We expect plain ssh for a connection

        def check_requirements
          ["ruby-libvirt","fog"].each do |gemname|
            unless gem_available?(gemname)
              raise Veewee::Error,"The kvm Builder requires the gem '#{gemname}' to be installed\n"    + "gem install #{gemname}"
            end
          end
        end

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

        end

      end #End Class
    end # End Module
  end # End Module
end # End Module
