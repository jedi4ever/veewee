module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        def vbox_version
          command="#{@vboxcmd} --version"
          shell_results=shell_exec("#{command}",{:mute => true})
          version=shell_results.stdout.strip.split('r')[0]
          return version
        end

      end
    end
  end
end
