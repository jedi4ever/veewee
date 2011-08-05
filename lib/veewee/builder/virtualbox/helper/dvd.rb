module Veewee
  module Builder
    module Virtualbox

      def attach_isofile
        full_iso_file=File.join(@environment.iso_dir,@definition.iso_file)
        puts "Mounting cdrom: #{full_iso_file}"
        #command => "${vboxcmd} storageattach '${vname}' --storagectl 'IDE Controller' --type dvddrive --port 1 --device 0 --medium '${isodst}' ";
        command ="#{@vboxcmd} storageattach '#{@box_name}' --storagectl 'IDE Controller' --type dvddrive --port 1 --device 0 --medium '#{full_iso_file}'"
        Veewee::Util::Shell.execute("#{command}")
      end
      
    end
  end
end
