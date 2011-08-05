module Veewee
  module Builder
    module Virtualbox

      def add_ide_controller
        #unless => "${vboxcmd} showvminfo '${vname}' | grep 'IDE Controller' "
        command ="#{@vboxcmd} storagectl '#{@box_name}' --name 'IDE Controller' --add ide"
        Veewee::Util::Shell.execute("#{command}")
      end

      def add_sata_controller
        #unless => "${vboxcmd} showvminfo '${vname}' | grep 'SATA Controller' ";
        command ="#{@vboxcmd} storagectl '#{@box_name}' --name 'SATA Controller' --add sata --hostiocache #{@definition.hostiocache}"
        Veewee::Util::Shell.execute("#{command}")
      end

    end
  end
end
