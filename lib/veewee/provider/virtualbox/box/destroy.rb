module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        def destroy(option={})

          unless self.exists?
            raise Veewee::Error, "Error:: You tried to destroy a non-existing box '#{name}'"
          end

          # If it has a save state,remove that first

          if self.running?
            # Poweroff
            self.poweroff
            # Wait for it to happen
            sleep 2
          end

          command="#{@vboxcmd} unregistervm  \"#{name}\" --delete"
          ui.info command
          ui.info "Deleting vm #{name}"

          #Exec and system stop the execution here
          shell_exec("#{command}",{:mute => true})
          sleep 1

          #if the disk was not attached when the machine was destroyed we also need to delete the disk
          pattern= File::SEPARATOR+name+"."
          #+definition.disk_format.downcase
          found=false
          command="#{@vboxcmd} list hdds -l"
          hdds=shell_exec("#{command}",{:mute => true}).stdout.split(/\n\n/)

          hdds.each do |hdd_text|
            location=hdd_text.split(/\n/).grep(/^Location/).first.split(':')[1].strip
            if location.match(/#{pattern}/)

              if File.exists?(location)
                command="#{@vboxcmd} closemedium disk \"#{location}\" --delete"
              else
                command="#{@vboxcmd} closemedium disk \"#{location}\""
              end

              ui.info "Deleting disk #{location}"
              ui.info "#{command}"

              shell_exec("#{command}",{:mute => true})

              if File.exists?(location)
                ui.info "We tried to delete the disk file via virtualbox '#{location} but failed"
                ui.info "Removing it manually"
                FileUtils.rm(location)
              end
              break
            end
          end
        end

      end #Module
    end #Module
  end #Module
end #Module
