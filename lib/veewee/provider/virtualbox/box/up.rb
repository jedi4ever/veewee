module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        def up(options={})

          unless self.exists?
            raise Veewee::Error, "Error:: You tried to up a non-existing box '#{name}'"
          end

          gui_enabled=options['nogui']==true ? false : true

          raise Veewee::Error,"Box is already running" if self.running?

          # Before we start,correct the ssh port if needed
          forward=self.forwarding("guestssh")
          guessed_port=guess_free_port(definition.ssh_host_port.to_i,definition.ssh_host_port.to_i+40).to_s
          definition.ssh_host_port=guessed_port.to_s

          unless forward.nil?
            if guessed_port!=forward[:guest_port]
              # Remove the existing one
              self.delete_forwarding("guestssh")
              ui.warn "Changing ssh port from #{forward[:guest_port]} to #{guessed_port}"
              self.add_ssh_nat_mapping
            end
          else
            self.add_ssh_nat_mapping
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
