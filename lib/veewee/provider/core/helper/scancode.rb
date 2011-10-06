module Veewee
  module Provider
    module Core
      module Helper
        class Scancode

          def self.string_to_keycode(thestring)

            #http://www.win.tue.nl/~aeb/linux/kbd/scancodes-1.html

            k=Hash.new
            k['1'] = '02 82' ; k['2'] = '03 83' ; k['3'] = '04 84'; k['4']= '05 85' ;
            k['5']='06 86'; k['6'] = '07 87' ; k['7'] = '08 88'; k['8'] = '09 89'; k['9']= '0a 8a';
            k['0']='0b 8b'; k['-'] = '0c 8c'; k['='] = '0d 8d' ;
            k['Tab'] = '0f 8f';
            k['q']  = '10 90' ;       k['w']  = '11 91' ;       k['e']  = '12 92';
            k['r'] = '13 93'       ; k['t'] = '14 94'       ; k['y'] = '15 95';
            k['u']= '16 96'        ; k['i']='17 97';      k['o'] = '18 98'       ; k['p'] = '19 99' ;

            k['Q']  = '2a 10 aa' ; k['W']  = '2a 11 aa' ; k['E']  = '2a 12 aa'; k['R'] = '2a 13 aa' ; k['T'] = '2a 14 aa' ; k['Y'] = '2a 15 aa'; k['U']= '2a 16 aa' ; k['I']='2a 17 aa'; k['O'] = '2a 18 aa' ; k['P'] = '2a 19 aa' ;

            k['a'] = '1e 9e'; k['s']  = '1f 9f' ; k['d']  = '20 a0' ; k['f']  = '21 a1'; k['g'] = '22 a2' ; k['h'] = '23 a3' ; k['j'] = '24 a4';
            k['k']= '25 a5' ; k['l']='26 a6';
            k['A'] = '2a 1e aa 9e'; k['S']  = '2a 1f aa 9f' ; k['D']  = '2a 20 aa a0' ; k['F']  = '2a 21 aa a1';
            k['G'] = '2a 22 aa a2' ; k['H'] = '2a 23 aa a3' ; k['J'] = '2a 24 aa a4'; k['K']= '2a 25 aa a5' ; k['L']='2a 26 aa a6';

            k[';'] = '27 a7' ;k['"']='2a 28 aa a8';k['\'']='28 a8';

            k['\\'] = '2b ab';   k['|'] = '2a 2b aa 8b';

            k['[']='1a 9a'; k[']']='1b 9b';
            k['<']='2a 33 aa b3'; k['>']='2a 34 aa b4';
            k['$']='2a 05 aa 85';
            k['+']='2a 0d aa 8d';

            k['?']='2a 35 aa b5';
            k['z'] = '2c ac'; k['x']  = '2d ad' ; k['c']  = '2e ae' ; k['v']  = '2f af'; k['b'] = '30 b0' ; k['n'] = '31 b1' ;
            k['m'] = '32 b2';
            k['Z'] = '2a 2c aa ac'; k['X']  = '2a 2d aa ad' ; k['C']  = '2a 2e aa ae' ; k['V']  = '2a 2f aa af';
            k['B'] = '2a 30 aa b0' ; k['N'] = '2a 31 aa b1' ; k['M'] = '2a 32 aa b2';

            k[',']= '33 b3' ; k['.']='34 b4'; k['/'] = '35 b5' ;k[':'] = '2a 27 aa a7';
            k['%'] = '2a 06 aa 86';  k['_'] = '2a 0c aa 8c';
            k['&'] = '2a 08 aa 88';
            k['('] = '2a 0a aa 8a';
            k[')'] = '2a 0b aa 8b';


            special=Hash.new;
            special['<Enter>'] = '1c 9c';
            special['<Backspace>'] = '0e 8e';
            special['<Spacebar>'] = '39 b9';
            special['<Return>'] = '1c 9c'
            special['<Esc>'] = '01 81';
            special['<Tab>'] = '0f 8f';
            special['<KillX>'] = '1d 38 0e';
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

            special['<F1>'] = '3b';
            special['<F2>'] = '3c';
            special['<F3>'] = '3d';
            special['<F4>'] = '3e';
            special['<F5>'] = '3f';
            special['<F6>'] = '40';
            special['<F7>'] = '41';
            special['<F8>'] = '42';
            special['<F9>'] = '43';
            special['<F10>'] = '44';

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
                  env.ui.info "no scan code for #{thestring.slice(0,1)}"
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
