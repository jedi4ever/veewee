module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        # Return the major/minor/incremental version of VirtualBox.
        # For example: 4.1.8_Debianr75467 -> 4.1.8
        def vbox_version
          command="#{@vboxcmd} --version"
          shell_results=shell_exec("#{command}",{:mute => true})
          version=shell_results.stdout.strip.split(/[^0-9\.]/)[0]
          return version
        end

        def vboxga_version
          affected_version?(self.vbox_version) ? "4.2.0" : self.vbox_version
        end
      protected
        def affected_version?(ver)
          RUBY_PLATFORM.downcase.include?("darwin") && ver == "4.2.1"
        end
      end
    end
  end
end
