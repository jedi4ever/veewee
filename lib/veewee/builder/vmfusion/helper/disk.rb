module Veewee
  module Builder
    module Vmfusion
      
      def create_disk
        #Disk types:
        #    0                   : single growable virtual disk
        #    1                   : growable virtual disk split in 2GB files
        #    2                   : preallocated virtual disk
        #    3                   : preallocated virtual disk split in 2GB files
        #    4                   : preallocated ESX-type virtual disk
        #    5                   : compressed disk optimized for streaming
        #    6                   : thin provisioned virtual disk - ESX 3.x and above
        disk_type=1
        current_dir=FileUtils.pwd
        FileUtils.chdir(vm_path)
        command="#{fusion_path.shellescape}/vmware-vdiskmanager -c -s #{@definition.disk_size}M -a lsilogic -t #{disk_type} #{@box_name}.vmdk"
        Veewee::Util::Shell.execute(command)
        FileUtils.chdir(current_dir)
      end

    end
  end
end
