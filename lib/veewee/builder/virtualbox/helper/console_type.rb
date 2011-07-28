require 'veewee/util/scancode'
require 'veewee/util/tcp'
require 'veewee/util/shell'

module Veewee
  module Builder
    module Virtualbox
      def console_type(command,type_options={})
        send_sequence(command)
      end
      
      def send_sequence(sequence)
        puts
        counter=0
        sequence.each { |s|
          counter=counter+1

          s.gsub!(/%IP%/,Veewee::Util::Tcp.local_ip);
          s.gsub!(/%PORT%/,@definition.kickstart_port);
          s.gsub!(/%NAME%/, @box_name);
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
        command= "#{@vboxcmd} controlvm '#{@box_name}' keyboardputscancode #{keycode}"
        #puts "#{command}"
        Veewee::Util::Shell.execute("#{command}")
      end
      
end #Module
end #Module
end #Module