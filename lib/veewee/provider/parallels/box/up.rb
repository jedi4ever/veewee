module Veewee
  module Provider
    module Parallels
      module BoxCommand

        def up(options={})
          gui_enabled=options[:nogui]==true ? false : true
          command="prlctl start '#{self.name}'"
          shell_exec("#{command}")
        end

      end
    end
  end
end
