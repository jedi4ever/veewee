module Veewee
  module Provider
    module Core
      module BoxCommand

        def sudo(scriptname)
          if definition.ssh_user=="root"
            return "#{scriptname}"
          else
            command=definition.sudo_cmd
            newcommand=command.gsub(/%p/,"#{definition.ssh_password}")
            newcommand.gsub!(/%u/,"#{definition.ssh_user}")
            newcommand.gsub!(/%f/,"#{scriptname}")
            return newcommand
          end
        end

      end #Module
    end #Module
  end #Module
end #Module
