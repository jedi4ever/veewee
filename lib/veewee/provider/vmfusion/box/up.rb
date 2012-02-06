module Veewee
  module Provider
    module Vmfusion
      module BoxCommand

        def up(options={})
          gui_enabled=options[:nogui]==true ? false : true
          if gui_enabled
            raw.start unless raw.nil?
          else
            raw.start({:headless => true}) unless raw.nil?
          end
        end

      end
    end
  end
end
