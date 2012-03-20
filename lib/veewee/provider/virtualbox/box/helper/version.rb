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

      end
    end
  end
end
