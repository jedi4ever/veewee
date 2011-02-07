module Veewee
  class Scancode
  
    def self.send_sequence(vboxcmd,vname,sequence)
            puts
            counter=0
            sequence.each { |s|
              counter=counter+1
 
              s.gsub!(/%IP%/,Veewee::Session.local_ip);
              s.gsub!(/%PORT%/,'7122');
              s.gsub!(/%NAME%/, vname);
              puts "Typing:[#{counter}]: "+s

              keycodes=string_to_keycode(s)
      
              # VBox seems to have issues with sending the scancodes as one big
              # .join()-ed string. It seems to get them out or order or ignore some.
              # A workaround is to send the scancodes one-by-one.
              codes=""
              for keycode in keycodes.split(' ') do
                   send_keycode(vboxcmd,vname,keycode)    
                   sleep 0.01                  
              end
        	    #sleep after each sequence (needs to be param)
        	    sleep 1
    	    }

          puts "Done typing."
          puts
  
    end

    def self.send_keycode(vboxcmd,vname,keycode)
           command= "#{vboxcmd} controlvm '#{vname}' keyboardputscancode #{keycode}"
           #puts "#{command}"
                  IO.popen("#{command}") { |f| print '' }
    end

    def self.string_to_keycode(thestring)
  
      #http://www.win.tue.nl/~aeb/linux/kbd/scancodes-1.html
  
            k=Hash.new
            k['1'] = '02' ; k['2'] = '03' ; k['3'] = '04'; k['4']= '05' ;k['5']='06'; k['6'] = '07' ; k['7'] = '08'; k['8'] = '09'; k['9']= '0a'; k['0']='0b'; k['-'] = '0c'; k['='] = '0d' ;
            k['Tab'] = '0f'; 
            k['q']  = '10' ;       k['w']  = '11' ;       k['e']  = '12';       k['r'] = '13'       ; k['t'] = '14'       ; k['y'] = '15';      k['u']= '16'        ; k['i']='17';      k['o'] = '18'       ; k['p'] = '19' ; 
           
            k['Q']  = '2a 10 aa' ; k['W']  = '2a 11 aa' ; k['E']  = '2a 12 aa'; k['R'] = '2a 13 aa' ; k['T'] = '2a 14 aa' ; k['Y'] = '2a 15 aa'; k['U']= '2a 16 aa' ; k['I']='2a 17 aa'; k['O'] = '2a 18 aa' ; k['P'] = '2a 19 aa' ;

            k['a'] = '1e'; k['s']  = '1f' ; k['d']  = '20' ; k['f']  = '21'; k['g'] = '22' ; k['h'] = '23' ; k['j'] = '24'; k['k']= '25' ; k['l']='26'; k[';'] = '27' 
            k['A'] = '2a 1e aa'; k['S']  = '2a 1f aa' ; k['D']  = '2a 20 aa' ; k['F']  = '2a 21 aa'; k['G'] = '2a 22 aa' ; k['H'] = '2a 23 aa' ; k['J'] = '2a 24 aa'; k['K']= '2a 25 aa' ; k['L']='2a 26 aa'; 
            
            k[';'] = '27' ;k['"']='28';

            k['[']='1a'; k[']']='1b'

            k['z'] = '2c'; k['x']  = '2d' ; k['c']  = '2e' ; k['v']  = '2f'; k['b'] = '30' ; k['n'] = '31' ; k['m'] = '32';
            k['Z'] = '2a 2c aa'; k['X']  = '2a 2d aa' ; k['C']  = '2a 2e aa' ; k['V']  = '2a 2f aa'; k['B'] = '2a 30 aa' ; k['N'] = '2a 31 aa' ; k['M'] = '2a 32 aa';
            
            k[',']= '33' ; k['.']='34'; k['/'] = '35' ;k[':'] = '2a 27 aa';
            k['%'] = '2a 06 aa';  k['_'] = '2a 0c aa';

          special=Hash.new;
          special['<Enter>'] = '1c';
          special['<Backspace>'] = '0e';
          special['<Spacebar>'] = '39';
          special['<Return>'] = '1c'
          special['<Esc>'] = '01';
          #special['<Up>'] = '01';
          #special['<Down>'] = '01';
          #special['<PageUp>'] = '01';
          #special['<PageDown>'] = '01';

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
                puts "no scan code for #{thestring.slice(0,1)}"
              end
              #pop one
              thestring=thestring.slice(1,thestring.length-1)
            end
          end

            return keycodes
    end

  end
end


