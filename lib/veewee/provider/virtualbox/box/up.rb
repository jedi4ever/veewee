module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        def up(options={})

          unless self.exists?
            raise Veewee::Error, "Error:: You tried to up a non-existing box '#{name}'. Please run 'veewee vbox build #{name}' first."
          end

          gui_enabled=options['nogui']==true ? false : true

          raise Veewee::Error,"Box is already running" if self.running?

          if definition.winrm_user && definition.winrm_password # prefer winrm 
            # Before we start,correct the ssh/winrm port if needed
            forward=self.forwarding("guestwinrm")
            guessed_port=guess_free_port(definition.winrm_host_port.to_i,definition.winrm_host_port.to_i+40).to_s
            definition.winrm_host_port=guessed_port.to_s
            
            unless forward.nil?
              if guessed_port!=forward[:host_port]
                # Remove the existing one
                self.delete_forwarding("guestwinrm")
                env.ui.warn "Changing winrm port on UP from #{forward[:host_port]} to #{guessed_port}"
              self.add_winrm_nat_mapping
              end
            else
              self.add_winrm_nat_mapping
            end
            
          else

            # Before we start,correct the ssh port if needed
            forward=self.forwarding("guestssh")
            guessed_port=guess_free_ssh_port(definition.ssh_host_port.to_i,definition.ssh_host_port.to_i+40).to_s
            definition.ssh_host_port=guessed_port.to_s
            
            unless forward.nil?
              if guessed_port!=forward[:host_port]
                # Remove the existing one
                self.delete_forwarding("guestssh")
                env.ui.warn "Changing ssh port from #{forward[:host_port]} to #{guessed_port}"
              self.add_ssh_nat_mapping
              end
            else
              self.add_ssh_nat_mapping
            end
            
          end

          self.suppress_messages

          # Once assembled we start the machine
          env.logger.info "Started the VM with GUI Enabled? #{gui_enabled}"

          command="#{@vboxcmd} startvm --type gui \"#{name}\""
          unless (gui_enabled)
            command="#{@vboxcmd} startvm --type headless \"#{name}\""
          end
          shell_results=shell_exec("#{command}",{:mute => true})
        end

      end
    end
  end
end
