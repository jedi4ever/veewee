require 'veewee/provider/core/helper/scancode'
require 'veewee/provider/core/helper/tcp'
require 'veewee/provider/core/helper/shell'

module Veewee
  module Provider
    module Virtualbox
      module BoxCommand
        def console_type(sequence)
          send_virtualbox_sequence(sequence)
        end

        def send_virtualbox_sequence(sequence)

          env.ui.info ""

          counter=0
          sequence.each { |s|
            counter=counter+1

            env.ui.info "Typing:[#{counter}]: "+s

            keycodes=Veewee::Provider::Core::Helper::Scancode.string_to_keycode(s)

            # VBox seems to have issues with sending the scancodes as one big
            # .join()-ed string. It seems to get them out or order or ignore some.
            # A workaround is to send the scancodes one-by-one.
            codes=""
            for keycode in keycodes.split(' ') do
              unless keycode=="wait"
                send_keycode(keycode)
                sleep 0.01
              else
                sleep 1
              end
            end
            #sleep after each sequence (needs to be param)
            sleep 0.5
          }

          env.ui.info "Done typing."
          env.ui.info ""

        end

        def send_keycode(keycode)
          command= "#{@vboxcmd} controlvm '#{name}' keyboardputscancode #{keycode}"
          env.logger.info "#{command}"
          sshresult=shell_exec("#{command}",{:mute => true})
          unless sshresult.stdout.index("E_ACCESSDENIED").nil?
            env.ui.error "There was an error typing the commands on the console"
            env.ui.error "Probably the VM did not get started."
            env.ui.error ""
            env.ui.error "#{sshresult.stdout}"
            exit -1
          end
        end

      end #Module
    end #Module
  end #Module
end #Module
