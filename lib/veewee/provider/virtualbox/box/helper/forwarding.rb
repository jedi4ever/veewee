module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        def forwarding(name)
          command="#{@vboxcmd} showvminfo --details --machinereadable \"#{self.name}\""
          shell_results=shell_exec("#{command}")
          rules=shell_results.stdout.split(/\n/).grep(/^Forward/)
          result=nil
          rules.each do |rule|
            #Forwarding(0)
            nr=rule.split('=')[0].split('(')[1].split(')')[0].to_i + 1
            #  guestssh,tcp,,2222,,22
            details=rule.split('=')[1].split('"')[1].split(',')
            result = {
              :nr => nr,
              :name => details[0],
              :protocol => details[1],
              :host_ip => details[2],
              :host_port => details[3],
              :guest_ip => details[4],
              :guest_port => details[5]
            }
          end
          return result
        end

        def delete_forwarding(name)
          forward=self.forwarding(name)
          if self.running?
            command="#{@vboxcmd} controlvm \"#{self.name}\" natpf#{self.natinterface} delete \"#{name}\""
          else
            command="#{@vboxcmd} modifyvm \"#{self.name}\" --natpf#{self.natinterface} delete \"#{name}\""
          end
          shell_results=shell_exec("#{command}")
        end

      end
    end
  end
end
