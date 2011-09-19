module Veewee
  module Builder
    module Virtualbox

      def destroy(destroy_options={})

        #:destroy_medium => :delete,  will delete machine + all media attachments
        #vm.destroy(:destroy_medium => :delete)
        ##vm.destroy(:destroy_image => true)

        #VBoxManage unregistervm "test-machine" --delete
        #because the destroy does remove the .vbox file on 4.0.x
        #PDB
        #vm.destroy()

        vm=VirtualBox::VM.find(@box_name)

        if (!vm.nil? && !(vm.powered_off?))
          puts "Shutting down vm #{@box_name}"
          #We force it here, maybe vm.shutdown is cleaner
          begin
            vm.stop
          rescue VirtualBox::Exceptions::InvalidVMStateException
            puts "There was problem sending the stop command because the machine is in an Invalid state"
            puts "Please verify leftovers from a previous build in your vm folder"
          end
          sleep 3
        end     

        command="#{@vboxcmd} unregistervm  '#{@box_name}' --delete"    
        puts command
        puts "Deleting vm #{@box_name}"

        #Exec and system stop the execution here
        Veewee::Util::Shell.execute("#{command}")
        sleep 1

        #if the disk was not attached when the machine was destroyed we also need to delete the disk
        location=@box_name+"."+@definition.disk_format.downcase
        found=false       
        VirtualBox::HardDrive.all.each do |d|
          if d.location.match(/#{location}/)

            if File.exists?(d.location) 
              command="#{@vboxcmd} closemedium disk '#{d.location}' --delete"
            else
              command="#{@vboxcmd} closemedium disk '#{d.location}'"        
            end

            #command="#{@vboxcmd} closemedium disk '#{d.location}' --delete"
            puts "Deleting disk #{d.location}"
            puts "#{command}"

            Veewee::Util::Shell.execute("#{command}") 

            if File.exists?(d.location) 
              puts "We tried to delete the disk file via virtualbox '#{d.location} but failed"
              puts "Removing it manually"
              FileUtils.rm(d.location)
              exit
            end 
            #v.3
            #d.destroy(true)
            break
          end
        end     
      end

    end #Module
  end #Module
end #Module
