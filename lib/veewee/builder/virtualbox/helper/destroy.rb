module Veewee
  module Builder
    module Virtualbox
      module BoxHelper
        
      def destroy
        
        # If it has a save state,remove that first
        if raw.saved?
          env.ui.info "Removing save state"
          raw.discard_state
          raw.reload
        end
        
        # If the machine was in pause it is locked
        # The we must do a poweroff
          
        env.logger.info "anything here?"
        #:destroy_medium => :delete,  will delete machine + all media attachments
        #vm.destroy(:destroy_medium => :delete)
        ##vm.destroy(:destroy_image => true)

        #VBoxManage unregistervm "test-machine" --delete
        #because the destroy does remove the .vbox file on 4.0.x
        #PDB
        #vm.destroy()

        command="#{@vboxcmd} unregistervm  '#{name}' --delete"    
        env.ui.info command
        env.ui.info "Deleting vm #{name}"

        #Exec and system stop the execution here
        Veewee::Util::Shell.execute("#{command}")
        sleep 1

        #if the disk was not attached when the machine was destroyed we also need to delete the disk
        location=name+"."
        #+definition.disk_format.downcase
        found=false       
        VirtualBox::HardDrive.all.each do |d|
          if d.location.match(/#{location}/)

            if File.exists?(d.location) 
              command="#{@vboxcmd} closemedium disk '#{d.location}' --delete"
            else
              command="#{@vboxcmd} closemedium disk '#{d.location}'"        
            end

            #command="#{@vboxcmd} closemedium disk '#{d.location}' --delete"
            env.ui.info "Deleting disk #{d.location}"
            env.ui.info "#{command}"

            Veewee::Util::Shell.execute("#{command}") 

            if File.exists?(d.location) 
              env.ui.info "We tried to delete the disk file via virtualbox '#{d.location} but failed"
              env.ui.info "Removing it manually"
              FileUtils.rm(d.location)
              exit -1
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
end #Module
