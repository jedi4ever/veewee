module Veewee
  module Provider
    module Core
      module Helper
        class Scancode

          def self.string_to_keycode(thestring)

            #http://www.win.tue.nl/~aeb/linux/kbd/scancodes-1.html

            # keycode hash, seeded with 'Tab' - which is special as it's longer than 1 char
            k = { 'Tab' => '0f 8f' }
            
            # add keycodes

            # "pure" keys (no modifier keys)
            lower_keys = {
              '1234567890-='  => 0x02,
              'qwertyuiop[]'  => 0x10,
              'asdfghjkl;\'`' => 0x1e,
              '\\zxcvbnm,./'  => 0x2b
            }.each do |keys, offset|
              keys.split('').each_with_index do |key, idx|
                k[key] = sprintf('%02x %02x', idx + offset, idx + offset + 0x80)
              end
            end

            # upcase keys (with shift)
            {
              '!@#$%^&*()_+'  => 0x02,
              'QWERTYUIOP{}'  => 0x10,
              'ASDFGHJKL:"~'  => 0x1e,
              '|ZXCVBNM<>?'   => 0x2b
            }.each do |keys, offset|
              keys.split('').each_with_index do |key, idx|
                k[key] = sprintf('2a %02x aa %02x', idx + offset, idx + offset + 0x80)
              end
            end
            
            special=Hash.new;
            special['<Enter>'] = '1c 9c';
            special['<Backspace>'] = '0e 8e';
            special['<Spacebar>'] = '39 b9';
            special['<Return>'] = '1c 9c'
            special['<Esc>'] = '01 81';
            special['<Tab>'] = '0f 8f';
            special['<KillX>'] = '1d 38 0e b8';
            special['<Wait>'] = 'wait';

            special['<Up>'] = '48 c8';
            special['<Down>'] = '50 d0';
            special['<PageUp>'] = '49 c9';
            special['<PageDown>'] = '51 d1';
            special['<End>'] = '4f cf';
            special['<Insert>'] = '52 d2';
            special['<Delete>'] = '53 d3';
            special['<Left>'] = '4b cb';
            special['<Right>'] = '4d cd';
            special['<Home>'] = '47 c7';

            # F1 .. F10
            (1..10).each { |num| special["<F#{num}>"] = sprintf('%02x', num + 0x3a) }

            keycodes=''
            thestring.gsub!(/ /,"<Spacebar>")

            until thestring.length == 0
              nospecial=true;
              special.keys.each { |key|
                if thestring.start_with?(key)
                  #take thestring
                  #check if it starts with a special key + pop special string
                  keycodes=keycodes+special[key]+' ';
                  thestring=thestring.slice(key.length,thestring.length-key.length)
                  nospecial=false;
                  break;
                end
              }
              if nospecial
                code=k[thestring.slice(0,1)]
                if !code.nil?
                  keycodes=keycodes+code+' '
                else
                  ui.error "no scan code for #{thestring.slice(0,1)}"
                end
                #pop one
                thestring=thestring.slice(1,thestring.length-1)
              end
            end

            return keycodes
          end
        end #Class
      end #Module
    end #Module
  end #Module
end #Module
