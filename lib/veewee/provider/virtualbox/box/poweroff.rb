module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        def poweroff(options={})
          # If the vm is not powered off, perform a shutdown
          if (self.exists? && self.running?)
            ui.info "Shutting down vm #{name}"
            #We force it here, maybe vm.shutdown is cleaner
            command="#{@vboxcmd} controlvm \"#{name}\" poweroff"
            shell_exec("#{command}")
          end
        end

      end
    end
  end
end
