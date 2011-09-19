require 'veewee/builder/core/builder'

require 'virtualbox'
#require 'virtualbox/abstract_model'
#require 'virtualbox/ext/byte_normalizer'

require 'veewee/builder/core/builder'

module Veewee
  module Builder
    module Virtualbox
    class Builder < Veewee::Builder::Core::Builder

      def list_ostypes(list_options={})
          return VirtualBox::Global.global.lib.virtualbox.guest_os_types
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
