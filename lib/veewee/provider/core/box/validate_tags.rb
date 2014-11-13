module Veewee
  module Provider
    module Core
      module BoxCommand

        def validate_tags(tags,options)

          unless self.exists?
            ui.error "Error:: You tried to validate box '#{name}' but it does not exist"
            exit -1
          end

          unless self.running?
            ui.error "Error:: You tried to validate box '#{name}' but it is not running"
            exit -1
          end

          if definition.winrm_user && definition.winrm_password # prefer winrm
            checks = checks_windows
          else
            checks = checks_linux
          end

          # Some reject here based on tags
          checks.reject! { |c|
            tagged = false
            c[:tags].each do |t|
              tagged = true if tags.include?(t)
            end
            ! tagged
          }

          # Assume clean exitcode
          exitcode = 0

          # Loop over checks
          checks.each do |check|
            if check[:sudo]
              result = check_output_sudorun(check[:command],check[:expected_string])
            else
              result = check_output_run(check[:command],check[:expected_string])
            end

            if result[:match]
              ui.success("#{check[:description]} - OK")
            else
              ui.error("#{check[:description]} - FAILED")
              ui.error("Command: #{check[:command]}")
              ui.error("Expected string #{check[:expected_string]}")
              ui.error("Output: #{check[:output]}")
              exitcode = -1
            end
          end

          exit -1 if exitcode < 0
        end

        def check_output_sudorun(command,expected_string)
          result = { :command => command,
                     :expected_string => expected_string,
                     :output => nil
                   }

          begin
            self.exec("echo '#{command}' > /tmp/validation.sh && chmod a+x /tmp/validation.sh", :mute => true)
            sshresult = self.exec(self.sudo("/tmp/validation.sh"),:mute => true)

            result[:output]   = sshresult.stdout
            result[:match]    = ! sshresult.stdout.match(/#{expected_string}/).nil?
          rescue
            result[:match] = false
          end
          return result
        end

        def check_output_run(command,expected_string)
          result = { :command => command,
                     :expected_string => expected_string,
                     :output => nil
                   }

          begin
            sshresult = self.exec(command, {:exitcode => '*',:mute => true})
            result[:output]   = sshresult.stdout
            result[:match]    = ! sshresult.stdout.match(/#{expected_string}/).nil?
          rescue
            result[:match] = false
          end
          return result
        end

        def checks_linux
          return [
            { :description => 'Checking user',
              :tags => [ 'virtualbox','kvm', 'parallels'],
              :command => 'who am i',
              :expected_string => definition.ssh_user,
              :sudo => false
          },
          { :description => 'Checking sudo',
            :tags => [ 'virtualbox','kvm', 'parallels'],
            :command => 'whoami',
            :expected_string => 'root',
            :sudo => true
          },
          { :description => 'Checking passwordless sudo',
            :tags => [ 'virtualbox','kvm', 'parallels'],
            :command => 'echo '' | sudo -S -l 2>/dev/null | grep NOPASSWD 1>/dev/null; echo $?',
            :expected_string => '0',
            :sudo => false
          },
          { :description => 'Checking ruby',
            :tags => [ 'virtualbox','kvm', 'parallels','ruby'],
            :command => '. /etc/profile ;ruby --version 2> /dev/null 1> /dev/null;  echo $?',
            :expected_string => "0",
            :sudo => false
          },
          { :description => 'Checking gem',
            :tags => [ 'virtualbox','kvm', 'parallels','gem'],
            :command => '. /etc/profile ;gem --version 2> /dev/null 1> /dev/null;  echo $?',
            :expected_string => "0",
            :sudo => false
          },
          { :description => 'Checking chef',
            :tags => [ 'chef'],
            :command => '. /etc/profile ;chef-client --version 2> /dev/null 1>/dev/null; echo $?',
            :expected_string => "0",
            :sudo => false
          },
          { :description => 'Checking puppet',
            :tags => [ 'puppet'],
            :command => '. /etc/profile ;puppet --version 2> /dev/null 1>/dev/null; echo $?',
            :expected_string => "0",
            :sudo => false
          },
          { :description => 'Checking shared folder',
            :tags => [ 'vagrant'],
            :command => 'mount|grep veewee-validation; echo $?',
            :expected_string => "0",
            :sudo => false
          }
          ]
        end

        def checks_windows
          return [
            { :description => 'Checking user',
              :tags => [ 'virtualbox','kvm','vmfusion'],
              :command => 'whoami',
              :expected_string => definition.ssh_user,
              :sudo => false
          },
          { :description => 'Checking ruby',
            :tags => [ 'virtualbox','kvm','vmfusion'],
            :command => 'ruby --version > %TEMP%\devnull && echo %ERRORLEVEL%',
            :expected_string => "0",
            :sudo => false
          },
          { :description => 'Checking gem',
            :tags => [ 'virtualbox','kvm','vmfusion'],
            :command => 'gem --version > %TEMP%\devnull && echo %ERRORLEVEL%',
            :expected_string => "0",
            :sudo => false
          },
          { :description => 'Checking chef',
            :tags => [ 'chef'],
            :command => 'chef-client --version > %TEMP%\devnull && echo %ERRORLEVEL%',
            :expected_string => "0",
            :sudo => false
          },
          ]
        end
      end #Module

    end #Module
  end #Module
end #Module
