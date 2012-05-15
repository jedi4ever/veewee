module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        def screenshot(filename,options={})
          raise Veewee::Error, "The VM needs to exist before we can take a screenshot" unless self.exists?
          raise Veewee::Error, "The VM needs to be running before we can test a screenshot" unless self.running?
          # If the vm is not powered off, take a screenshot
          if (self.exists? && self.running?)
            ui.info "Saving screenshot of vm #{name} in #{filename}"

            command="#{@vboxcmd} controlvm \"#{name}\" screenshotpng \"#{filename}\""
            shell_exec("#{command}")
            unless File.exists?(filename)
              raise Veewee::Error,"Saving Screenshot #{filename} failed"
            end
          end
        end

      end
    end
  end
end
