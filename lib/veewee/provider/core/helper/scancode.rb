module Veewee
  module Provider
    module Core
      module Helper
        class Scancode

          #http://www.win.tue.nl/~aeb/linux/kbd/scancodes-1.html

          # keycode hash, seeded with 'Tab' - which is special as it's longer than 1 char
          @@keys = { 'Tab' => '0f 8f' }

          # add keycodes

          # "pure" keys (no modifier keys)
          {
              '1234567890-='  => 0x02,
              'qwertyuiop[]'  => 0x10,
              'asdfghjkl;\'`' => 0x1e,
              '\\zxcvbnm,./'  => 0x2b
          }.each do |keys, offset|
            keys.split('').each_with_index do |key, idx|
              @@keys[key] = sprintf('%02x %02x', idx + offset, idx + offset + 0x80)
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
              @@keys[key] = sprintf('2a %02x aa %02x', idx + offset, idx + offset + 0x80)
            end
          end

          @@special_keys = Hash.new;
          @@special_keys['<Enter>'] = '1c 9c';
          @@special_keys['<Backspace>'] = '0e 8e';
          @@special_keys['<Bs>'] = '0e 8e';
          @@special_keys['<Spacebar>'] = '39 b9';
          @@special_keys['<Return>'] = '1c 9c'
          @@special_keys['<Esc>'] = '01 81';
          @@special_keys['<Tab>'] = '0f 8f';
          @@special_keys['<KillX>'] = '1d 38 0e b8';
          @@special_keys['<Wait(\d*)>'] = 'wait';

          @@special_keys['<Up>'] = '48 c8';
          @@special_keys['<Down>'] = '50 d0';
          @@special_keys['<PageUp>'] = '49 c9';
          @@special_keys['<PageDown>'] = '51 d1';
          @@special_keys['<End>'] = '4f cf';
          @@special_keys['<Insert>'] = '52 d2';
          @@special_keys['<Delete>'] = '53 d3';
          @@special_keys['<Del>'] = '53 d3';
          @@special_keys['<Left>'] = '4b cb';
          @@special_keys['<Right>'] = '4d cd';
          @@special_keys['<Home>'] = '47 c7';

          # F1 .. F10
          (1..10).each { |num| @@special_keys["<F#{num}>"] = sprintf('%02x', num + 0x3a) }

          # VT1 - VT12 (Switch to Virtual Terminal #. e.g Alt+F1)
          (1..12).each { |num| @@special_keys["<VT#{num}>"] = sprintf('38 %02x b8 %02x', num + 0x3a, num + 0xba) }

          # the us keymap is used
          def self.string_to_keycode(thestring)
            keycodes=''
            thestring.gsub!(/ /,"<Spacebar>")

            until thestring.length == 0
              nospecial=true;
              @@special_keys.each { |key, value|
                if
                  result = thestring.match(/^#{key}/i)
                then
                  #take thestring
                  #check if it starts with a special key + pop special string
                  keycodes += value + result.captures.join(",") + ' '
                  thestring = thestring.slice(result.to_s.length, thestring.length-result.to_s.length)
                  nospecial = false;
                  break;
                end
              }
              if nospecial
                code=@@keys[thestring.slice(0,1)]
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
