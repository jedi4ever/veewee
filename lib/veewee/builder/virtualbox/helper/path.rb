module Veewee
  module Builder
    module Virtualbox

      def get_vm_location
        command="#{@vboxcmd}  list  systemproperties"
        shell_results=Veewee::Util::Shell.execute("#{command}",{:mute => true})
        place=shell_results.stdout.split(/\n/).grep(/Default machine/)[0].split(":")[1].strip
        return place
      end
      
    end
  end
end
