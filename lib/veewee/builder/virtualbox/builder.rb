require 'veewee/builder/core/builder'
require 'veewee/builder/virtualbox/helper/export_vagrant'
require 'veewee/builder/virtualbox/helper/validate_vagrant'

module Veewee
  module Builder
    module Virtualbox
      class Builder < Veewee::Builder::Core::Builder

        include ::Veewee::Builder::Virtualbox::BuilderHelper

        def check_requirements
          unless gem_available?("virtualbox")
            raise Veewee::Error,"The Virtualbox Builder requires the gem 'virtualbox' to be installed"
          end
        end

        def ssh_options(definition)
          ssh_options={
            :user => definition.ssh_user,
            :port => definition.ssh_host_port,
            :password => definition.ssh_password,
            :timeout => definition.ssh_login_timeout.to_i
          }
          return ssh_options

        end

        def build_info
          info=super
          info << { :filename => ".vbox_version",
                    :content => "#{VirtualBox::Global.global.lib.virtualbox.version.split('_')[0]}" }
        end

        def build(definition_name,box_name,options)

          super(definition_name,box_name,options)

          # w00t, we have succesfully reach this point
          # so we let user know , the vm is ready to be exported

        end

      end #End Class
    end # End Module
  end # End Module
end # End Module
