require 'veewee/builder/core/builder'

module Veewee
  module Builder
    module Virtualbox
    class Builder < Veewee::Builder::Core::Builder

      def ssh_options(definition) 
        ssh_options={ 
          :user => definition.ssh_user, 
          :port => definition.ssh_host_port,
          :password => definition.ssh_password,
          :timeout => definition.ssh_login_timeout.to_i
        }
        return ssh_options
        
      end
      
      def build(definition_name,box_name,options)
      
        super(definition_name,box_name,options)

        # w00t, we have succesfully reach this point
        # so we let user know , the vm is ready to be exported

        env.ui.info "#{box_name} was build succesfully. "
        env.ui.info ""
        env.ui.info "Now you can: "
        env.ui.info "- verify your box by running              : vagrant basebox validate #{box_name}"
        env.ui.info "- export your vm to a .box fileby running : vagrant basebox export   #{box_name}"
        
      end

      def transfer_buildinfo_file

        Veewee::Util::Ssh.when_ssh_login_works("localhost",ssh_options) do
          #Transfer version of Virtualbox to $HOME/.vbox_version            
          versionfile=Tempfile.open("vbox.version")
          versionfile.puts "#{VirtualBox::Global.global.lib.virtualbox.version.split('_')[0]}"
          versionfile.rewind
          begin
            Veewee::Util::Ssh.transfer_file("localhost",versionfile.path,".vbox_version", ssh_options)
          rescue RuntimeError
            puts "error transfering file, possible not enough permissions to write?"
          ensure
            versionfile.close
            versionfile.delete                
          end
          puts ""
        end
      end
      
    end #End Class
end # End Module
end # End Module
end # End Module
