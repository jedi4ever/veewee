# Include the gem library
require 'net/vnc'

# Monkey patch the vnc
require 'net/vnc/vnc.rb'

module Veewee
  module Provider
    module Core
      module BoxCommand

      def vnc_type(sequence,host,display=20)
        counter=0
        env.logger.info "Opening VNC #{host} on display #{display}"
        vnc=Net::VNC.open("#{host}:#{display}",{:wait => 0.001})
        sequence.each { |s|
          counter=counter+1

          env.ui.info "Typing:[#{counter}]: "+s

          keycodes=string_to_vnccode(s)

            keycodes.each do |keycode|
              if keycode==:wait
                sleep 1
              else
                send_vnc_keycode(vnc,keycode)
              end
            end
        }
        vnc.close
        env.ui.info "Done typing."
        env.ui.info ""

      end

      def send_vnc_keycode(vnc,keycode)

        if keycode.is_a?(Symbol)
          vnc.key_press keycode
          sleep 1
        else
            vnc.type_string keycode,{:wait => 0.1}
        end

      end


      def string_to_vnccode(thestring)

        # http://code.google.com/p/ruby-vnc/source/browse/trunk/data/keys.yaml

        special=Hash.new
        # Specific veewee
        special['<Wait>'] = :wait

        # VNC Codes
        special['<Enter>'] = :return
        special['<Return>'] =  :return
        special['<Esc>'] = :escape

        # These still need some work!
        special['<Backspace>'] = :backspace
        special['<Spacebar>'] = ' '
        special['<Tab>'] = :tab
        # Hmm, what would the equivalent be here
        special['<KillX>'] = '1d 38 0e';

        special['<Up>'] = :up
        special['<Down>'] = :down
        special['<PageUp>'] = :page_up
        special['<PageDown>'] = :page_down
        special['<End>'] = :end
        special['<Insert>'] = :insert
        special['<Delete>'] = :delete
        special['<Left>'] = :left
        special['<Right>'] = :right
        special['<Home>'] = :home

        special['<F1>'] = :f1
        special['<F2>'] = :f2
        special['<F3>'] = :f3
        special['<F4>'] = :f4
        special['<F5>'] = :f5
        special['<F6>'] = :f6
        special['<F7>'] = :f7
        special['<F8>'] = :f8
        special['<F9>'] = :f9
        special['<F10>'] = :f10

        keycodes=Array.new
        thestring.gsub!(/ /,"<Spacebar>")

        until thestring.length == 0
          nospecial=true;
          special.keys.each { |key|
            if thestring.start_with?(key)
              #take thestring
              #check if it starts with a special key + pop special string
              keycodes<<special[key];
              thestring=thestring.slice(key.length,thestring.length-key.length)
              nospecial=false;
              break;
            end
          }
          if nospecial
            code = thestring.slice(0,1)
            keycodes << code
            #pop one
            thestring=thestring.slice(1,thestring.length-1)
          end
        end

        return keycodes
      end


        end #Module
      end #Module
    end #Module
end #Module

