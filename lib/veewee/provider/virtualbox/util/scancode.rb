require 'veewee/util/scancode'
require 'veewee/util/tcp'

module Veewee
  module Provider
    module Virtualbox

      def send_sequence(sequence)
        puts
        counter=0
        sequence.each { |s|
          counter=counter+1

          s.gsub!(/%IP%/,Veewee::Util::Tcp.local_ip);
          s.gsub!(/%PORT%/,@definition.kickstart_port);
          s.gsub!(/%NAME%/, @boxname);
          puts "Typing:[#{counter}]: "+s

          keycodes=Veewee::Util::Scancode.string_to_keycode(s)

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
          sleep 1
        }

        puts "Done typing."
        puts

      end

      def send_keycode(keycode)
        command= "#{@vboxcmd} controlvm '#{@boxname}' keyboardputscancode #{keycode}"
        #puts "#{command}"
        IO.popen("#{command}") { |f| print '' }
      end

    end #Module
  end #Module
end #Module

