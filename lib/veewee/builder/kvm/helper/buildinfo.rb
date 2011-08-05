module Veewee
  module Builder
    module Kvm

      def transfer_buildinfo_file
        Veewee::Util::Ssh.when_ssh_login_works(ip_address,ssh_options) do
          #Transfer version of Fusion to $HOME/.vmfusion_version            
          versionfile=Tempfile.open("libvirt_version")
          # Todo get the version of fusion
          versionfile.puts "dont know yet"
          versionfile.rewind
          begin
            Veewee::Util::Ssh.transfer_file(ip_address,versionfile.path,".libvirt_version", ssh_options)
          rescue RuntimeError => ex
            puts "error transfering file, possible not enough permissions to write? #{ex}"
            exit
          ensure
            versionfile.close
            versionfile.delete
          end
          puts ""
        end
      end

    end
  end
end
