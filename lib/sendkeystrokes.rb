def send_sequence(vboxcmd,vname,sequence)
      cmd="";
        sequence.each { |s|
          keycodes=string_to_keycode(s)
          puts keycodes
          # VBox seems to have issues with sending the scancodes as one big
          # .join()-ed string. It seems to get them out or order or ignore some.
          # A workaround is to send the scancodes one-by-one.
          codes=""
          for keycode in keycodes.split(' ') do
                codes=codes+send_keycode(vboxcmd,vname,keycode)                      
          end
          cmd=cmd+codes+" sleep 1;" 
	    }
	    return cmd;   
end

def send_keycode(vboxcmd,vname,keycode)
 
      return "#{vboxcmd} controlvm '#{vname}' keyboardputscancode #{keycode} ;"
end

def string_to_keycode(thestring)
  
  #http://www.win.tue.nl/~aeb/linux/kbd/scancodes-1.html
  
        k=Hash.new
         k['1'] = '02' ; k['2'] = '03' ; k['3'] = '04'; k['4']= '05' ;k['5']='06'; k['6'] = '07' ; k['7'] = '08'; k['8'] = '09'; k['9']= '0a'; k['0']='0b'; k['-'] = '0c'; k['='] = '0d' ;
        k['Tab'] = '0f'; k['q']  = '10' ; k['w']  = '11' ; k['e']  = '12'; k['r'] = '13' ; k['t'] = '14' ; k['y'] = '15'; k['u']= '16' ; k['i']='17'; k['o'] = '18' ; k['p'] = '19' ; k['[']='1a'; k[']']='1b'
      k['Q']  = '2a 10 aa' ; k['W']  = '2a 11 aa' ; k['E']  = '2a 12 aa'; k['R'] = '2a 13 aa' ; k['t'] = '14' ; k['y'] = '15'; k['U']= '2a 16 aa' ; k['i']='17'; k['o'] = '18' ; k['p'] = '19' ;

        k['a'] = '1e'; k['s']  = '1f' ; k['d']  = '20' ; k['f']  = '21'; k['g'] = '22' ; k['h'] = '23' ; k['j'] = '24'; k['k']= '25' ; k['l']='26'; k[';'] = '27' ;k['"']='28';
        k['a'] = '1e'; k['S']  = '2a 1f aa' ; k['d']  = '20' ; k['f']  = '21'; k['g'] = '22' ; k['h'] = '23' ; k['j'] = '24'; k['k']= '25' ; k['l']='26'; k[';'] = '27' ;k['"']='28';

        k['z'] = '2c'; k['x']  = '2d' ; k['c']  = '2e' ; k['v']  = '2f'; k['b'] = '30' ; k['n'] = '31' ; k['m'] = '32'; k[',']= '33' ; k['.']='34'; k['/'] = '35' ;k[':'] = '2a 27 aa'
      k['_'] = '2a 0c aa';

      special=Hash.new;
      special['<Enter>'] = '1c';
      special['<Backspace>'] = '0e';
      special['<Spacebar>'] = '39';
      special['<Return>'] = '1c'
      special['<Esc>'] = '01';

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
          keycodes=keycodes+k[thestring.slice(0,1)]+' ';
          thestring=thestring.slice(1,thestring.length-1)
        end
      #else take the character + pop 1 character
      end

        return keycodes
end


module Puppet::Parser::Functions
  newfunction(:sendkeystrokes, :type => :rvalue) do |args|
    vboxcmd= args[0]
    vname = args[1]
    keystrokes = args[2]
    cmd=send_sequence(vboxcmd,vname,keystrokes)
	  return cmd
  end
end
