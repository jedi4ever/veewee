module Veewee
  module Builder
    module Virtualbox

      def create_disk
        #Now check the disks
        #Maybe one day we can use the name, now we have to check location
        #disk=VirtualBox::HardDrive.find(box_name)
        location=@box_name+"."+@definition.disk_format.downcase
        found=false       
        VirtualBox::HardDrive.all.each do |d|
          if !d.location.match(/#{location}/).nil?
            found=true
            break
          end
        end   

        #Sometimes the above doesn't find a registered harddisk, but the vdi files is still there
        if File.exists?(location)
          puts "#{location} file still exists but isn't registered"
          puts "Let me clean up that mess for you."
          FileUtils.rm(location)
        end
        
        if !found
          puts "Creating new harddrive of size #{@definition.disk_size.to_i} "

          #newdisk=VirtualBox::HardDrive.new
          #newdisk.format=@definition[:disk_format]
          #newdisk.logical_size=@definition[:disk_size].to_i

          #newdisk.location=location
          ##PDB: again problems with the virtualbox GEM
          ##VirtualBox::Global.global.max_vdi_size=1000000
          #newdisk.save

          place=get_vm_location
          command ="#{@vboxcmd} createhd --filename '#{place}/#{@box_name}/#{@box_name}.#{@definition.disk_format.downcase}' --size '#{@definition.disk_size.to_i}' --format #{@definition.disk_format.downcase}"
          Veewee::Util::Shell.execute("#{command}")
        end

      end

      def attach_disk
        
        place=get_vm_location
        location=@box_name+"."+@definition.disk_format.downcase

        location="#{place}/#{@box_name}/"+location
        puts "Attaching disk: #{location}"

        #command => "${vboxcmd} storageattach '${vname}' --storagectl 'SATA Controller' --port 0 --device 0 --type hdd --medium '${vname}.vdi'",
        command ="#{@vboxcmd} storageattach '#{@box_name}' --storagectl 'SATA Controller' --port 0 --device 0 --type hdd --medium '#{location}'"
        Veewee::Util::Shell.execute("#{command}")

      end
      
    end
  end
end
