module Veewee
  module Provider
    module Parallels
      module BoxCommand

        def poweroff(options={})
          command="prlctl stop '#{self.name}' --kill"
          shell_exec("#{command}")
        end

      end
    end
  end
end
