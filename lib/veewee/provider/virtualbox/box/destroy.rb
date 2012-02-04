module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        def destroy(option={})

          if raw.nil?
            env.ui.error "Error:: You tried to destroy a non-existing box '#{name}'"
            exit -1
          end

          # If it has a save state,remove that first
          if raw.saved?
            env.ui.info "Removing save state"
            raw.discard_state
            raw.reload
          end

          env.logger.info "Checking state: #{raw.state}"
          if raw.state.to_s=="running"
            # Poweroff
            raw.stop
            # Wait for it to happen
            sleep 2
          end
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
          shell_exec("#{command}")
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

            shell_exec("#{command}")

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
