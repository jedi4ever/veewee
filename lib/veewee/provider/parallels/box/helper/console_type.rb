module Veewee
  module Provider
    module Parallels
      module BoxCommand

        # Type on the console
        def console_type(sequence,type_options={})
          #FIXME
          send_sequence(sequence)
        end

        def send_sequence(sequence)

          ui.info ""

          counter=0
          sequence.each { |s|
            counter=counter+1

            ui.info "Typing:[#{counter}]: "+s

            keycodes=self.string_to_parallels_keycode(s)

            # A keycode is a hash {'code' => 'U' , 'state' => 'pressed'}
            keycodes.each do |keycode|
              unless keycode['code']=="wait"
                send_keycode(keycode)
                sleep 0.01
              else
                sleep 1
              end
            end
            #sleep after each sequence (needs to be param)
          }

          ui.info "Done typing."
          ui.info ""


        end

        def send_keycode(keycode)
          python_script=File.join(File.dirname(__FILE__),'..','..','..','..','..','python','parallels_send_key.py')
          command="python #{python_script} '#{self.name}' '#{keycode['code']}' '#{keycode['state']}'"
          shell_results=shell_exec("#{command}")
        end

        # Returns hash
        def k2h(key,state)
          return { 'code' => key, 'state' => state}
        end

        # Returns hash
        def press2h(key)
          k2h(key,'press')
        end

        # Returns hash
        def release2h(key)
          k2h(key,'release')
        end

        # Returns array
        def press_release(key)
          seq=Array.new
          seq << press2h(key)
          seq << release2h(key)
          return seq
        end

        # Returns array
        def shift(sequence)
          seq=Array.new
          seq << press2h('SHIFT_LEFT')
          sequence.each do |s|
            seq << s
          end
          seq << release2h('SHIFT_LEFT')
          return seq
        end

        def string_to_parallels_keycode(thestring)


          # Setup one key presses
          k=Hash.new
          for key in 'A'..'Z'
            k[key] = shift(press_release(key))
          end

          for key in 'a'..'z'
            k[key] = press_release(key.upcase)
          end

          for key in '0'..'9'
            k[key] = press_release(key.upcase)
          end

          k['>'] = shift(press_release('GREATER'))
          k['.'] = press_release('GREATER')
          k['<'] = shift(press_release('LESS'))
          k[':'] = shift(press_release('COLON'))
          k[';'] = press_release('COLON')
          k['/'] = press_release('SLASH')
          k[' '] = press_release('SPACE')
          k['-'] = press_release('MINUS')
          k['\''] = press_release('QUOTE')
          k['{'] = press_release('CBRACE_LEFT')
          k['}'] = press_release('CBRACE_RIGHT')
          k['`'] = press_release('TILDA')
          k['~'] = shift(press_release('TILDA'))

          k['_'] = shift(press_release('MINUS'))
          k['?'] = shift(press_release('SLASH'))
          k['"'] = shift(press_release('QUOTE'))
          k[')'] = shift(press_release('0'))
          k['!'] = shift(press_release('1'))
          k['@'] = shift(press_release('2'))
          k['#'] = shift(press_release('3'))
          k['$'] = shift(press_release('4'))
          k['%'] = shift(press_release('5'))
          k['^'] = shift(press_release('6'))
          k['&'] = shift(press_release('7'))
          k['*'] = shift(press_release('8'))
          k['('] = shift(press_release('9'))
          k['|'] = shift(press_release('BACKSLASH'))
          k[','] = press_release('LESS')
          k['\\'] = press_release('BACKSLASH')
          k['+'] = shift(press_release('PLUS'))
          k['='] = press_release('PLUS')

          # Setup special keys
          special=Hash.new;
          special['<Enter>'] = [{ 'code' => 'ENTER', 'state' => 'press' }]
          special['<Backspace>'] = [{ 'code' => 'BACKSPACE', 'state' => 'press' }]
          special['<Spacebar>'] = [{ 'code' => 'SPACE', 'state' => 'press' }]
          special['<Return>'] = [{ 'code' => 'RETURN', 'state' => 'press' }]
          special['<Esc>'] = [{ 'code' => 'ESC', 'state' => 'press' }]
          special['<Tab>'] = [{ 'code' => 'TAB', 'state' => 'press' }]
          #FIXME
          special['<KillX>'] = '1d 38 0e';
          special['<Wait>'] = [{'code' => 'wait', 'state' => ''}];

          special['<Up>'] = [{ 'code' => 'UP', 'state' => 'press' }]
          special['<Down>'] = [{ 'code' => 'DOWN', 'state' => 'press' }]
          special['<PageUp'] = [{ 'code' => 'PAGE_UP', 'state' => 'press' }]
          special['<PageDown'] = [{ 'code' => 'PAGE_DOWN', 'state' => 'press' }]
          special['<End>'] = [{ 'code' => 'END', 'state' => 'press' }]
          special['<Insert>'] = [{ 'code' => 'INSERT', 'state' => 'press' }]
          special['<Delete>'] = [{ 'code' => 'DELETE', 'state' => 'press' }]
          special['<Left>'] = [{ 'code' => 'LEFT', 'state' => 'press' }]
          special['<Right>'] = [{ 'code' => 'RIGHT', 'state' => 'press' }]
          special['<Home>'] = [{ 'code' => 'HOME', 'state' => 'press' }]

          for i in 1..12 do
            special["<F#{i}>"] = press_release("F#{i}")
          end

          keycodes=Array.new

          until thestring.length == 0
            nospecial=true;
            special.keys.each { |key|
              if thestring.start_with?(key)
                #take thestring
                #check if it starts with a special key + pop special string
                special[key].each do |c|
                  keycodes << c
                end
                thestring=thestring.slice(key.length,thestring.length-key.length)
                nospecial=false;
                break;
              end
            }
            if nospecial
              code=k[thestring.slice(0,1)]
              if !code.nil?
                code.each do |c|
                  keycodes << c
                end
              else
                ui.info "no scan code for #{thestring.slice(0,1)}"
              end
              #pop one
              thestring=thestring.slice(1,thestring.length-1)
            end
          end

          return keycodes
        end
      end
    end
  end
end


#
# {'WWW_FAVORITES': (224, 102), 'LESS': (51,), 'F23': (110,), 'F22': (109,), 'F21': (108,), 'F20': ( 107,), 'F24': (118,), 'VOLUME_DOWN': (224, 46), 'MINUS': (12,), 'EUROPE_1': (43,), 'ZENKAKU_HANKAKU': (118,), 'QUOTE': (40,), 'HANGUEL': (242,), '0': (11,), 'PLUS': (13,), '4': (5,), 'TAB': (15,),'8': (9,), 'RO': (115,), 'PAD_STAR': (55,), 'D': (32,), 'EJECT': (224, 99), 'HIRAGANA_KATAKANA': 112,), 'APP_MAIL': (224, 108), 'HANJA': (241,), 'L': (38,), 'P': (25,), 'T': (20,), 'SLASH': (53,, 'ENTER': (28,), 'X': (45,), 'KATAKANA': (120,), 'GREATER': (52,), 'APP_MY_COMPUTER': (224, 107), 'MENU': (224, 93), 'PAD_MINUS': (74,), 'WWW_REFRESH': (224, 103), 'PAD_SLASH': (224, 53), 'YEN':(125,), 'WWW_BACK': (224, 106), 'DELETE': (224, 83), 'MEDIA_PREV_TRACK': (224, 16), 'SYSTEM_WAKE': (224, 99), 'WWW_FORWARD': (224, 105), 'PAGE_UP': (224, 73), 'DOWN': (224, 80), 'MEDIA_STOP': (224, 36), 'BACKSPACE': (14,), 'HOME': (224, 71), 'CMD_LEFT': (224, 91), 'ALT_RIGHT': (224, 56), 'VOLUME_UP': (224, 48), 'APP_CALCULATOR': (224, 33), 'CBRACE_LEFT': (26,), 'WWW_STOP': (224, 104), 'SPACE': (57,), 'MEDIA_SELECT': (224, 109), 'MEDIA_NEXT_TRACK': (224, 25), '3': (4,), 'COLON': (39,),'PAD_PLUS': (78,), '7': (8,), 'TILDA': (41,), 'C': (46,), 'MUHENKAN': (123,), 'END': (224, 79), 'G': (34,), 'M': (50,), 'K': (37,), 'CMD_RIGHT': (224, 92), 'F18': (105,), 'F19': (106,), 'O': (24,, 'W': (17,), 'F12': (88,), 'F13': (100,), 'F10': (68,), 'F11': (87,), 'F16': (103,), 'F17': (104,), 'F14': (101,), 'F15': (102,), 'SYSTEM_POWER': (224, 94), 'PRINT_SCREEN': (224, 42, 224, 55), 'S': (31,), 'SHIFT_LEFT': (42,), 'PAD_3': (81,), 'U': (22,), 'SCROLL_LOCK': (70,), 'NUM_8': (9,), 'NUM_9': (10,), 'ALT_LEFT': (56,), 'NUM_0': (11,), 'NUM_1': (2,), 'NUM_2': (3,), 'NUM_3': (4,), 'NUM_4': (5,), 'NUM_5': (6,), 'NUM_6': (7,), 'NUM_7': (8,), 'WWW_SEARCH': (224, 101), 'HIRAGANA': (119,), 'BACKSLASH': (43,), 'MEDIA_PLAY_PAUSE': (224, 34), '2': (3,), '6': (7,), 'LEFT': (224, 75), 'B': (48,), 'F': (33,), 'HENKAN': (121,), 'N': (49,), 'R': (19,), 'NUM_LOCK': (69,), 'V': (47,), 'Z': (44,), 'EURO': (224, 51), 'F1': (59,), 'F2': (60,), 'F3': (61,), 'F4': (62,), 'F5': (63,), 'F6': (64,), 'F7': (65,), 'F8': (66,), 'F9': (67,), 'BREAK': (224, 70, 224, 198), 'CTRL_LEFT': (29,), CAPS_LOCK': (58,), 'UP': (224, 72), 'PRINT_SCREEN2': (224, 55), 'LESS_GREATER': (86,), 'PAUSE_BREAK': (225, 29, 69, 225, 157, 197), 'INSERT': (224, 82), 'CBRACE_RIGHT': (27,), '1': (2,), 'PAD_9':(73,), 'PAD_8': (72,), '5': (6,), 'H': (35,), '9': (10,), 'PAD_2': (80,), 'PAD_1': (79,), 'PAD_0': (82,), 'PAD_7': (71,), 'PAD_6': (77,), 'PAD_5': (76,), 'PAD_4': (75,), 'A': (30,), 'PAGE_DOWN': 224, 81), 'J': (36,), 'E': (18,), 'PC9800_KEYPAD': (92,), 'MUTE': (224, 32), 'I': (23,), 'DOLLAR': (224, 52), 'Q': (16,), 'SYSTEM_SLEEP': (224, 95), 'ESC': (1,), 'Y': (21,), 'PAD_DEL': (83,), 'BRAZILIAN_KEYPAD': (126,), 'RIGHT': (224, 77), 'SHIFT_RIGHT': (54,), 'PAD_EQUAL': (89,), 'PAD_ENTER': (224, 28), 'SYSRQ': (84,), 'WWW_HOME': (224, 50), 'CTRL_RIGHT': (224, 29)}
