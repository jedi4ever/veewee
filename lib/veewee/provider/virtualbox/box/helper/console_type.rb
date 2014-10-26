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

          ui.info ""

          counter=0
          sequence.each { |s|
            counter=counter+1

            ui.info "Typing:[#{counter}]: "+s

            keycodes=Veewee::Provider::Core::Helper::Scancode.string_to_keycode(s)

            env.logger.info "Sending keycodes: #{keycodes}"

            # VBox seems to have issues with sending the scancodes as one big
            # .join()-ed string. It seems to get them out or order or ignore some.
            # A workaround is to send the scancodes one-by-one.
            codes=""
            for keycode in keycodes.split(' ') do
              case keycode
              when /^wait(\d*)$/ then sleep_guess($1)
              else
                send_keycode(keycode)
                sleep 0.01
              end
            end
            #sleep after each sequence (needs to be param)
            sleep 0.5
          }

          ui.info "Done typing."
          ui.info ""

        end

        def sleep_guess(str)
          str = "1" if str == ""
          sleep str.to_i
        end

        def send_keycode(keycode)
          command= "#{@vboxcmd} controlvm \"#{name}\" keyboardputscancode #{keycode}"
          env.logger.debug "#{command}"
          sshresult = shell_exec("#{command}",{:mute => true})
          env.logger.debug "\
sshresult.stdout: #{sshresult.stdout.inspect},
sshresult.stderr: #{sshresult.stderr.inspect}"
          if sshresult.stdout.index("E_ACCESSDENIED")
            error= "There was an error typing the commands on the console"
            error+="Probably the VM did not get started."
            error+= ""
            error+= "#{sshresult.stdout}"
            raise Veewee::Error, error
          end
        end

      end #Module
    end #Module
  end #Module
end #Module
