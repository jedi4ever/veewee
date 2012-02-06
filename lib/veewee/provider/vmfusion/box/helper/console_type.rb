module Veewee
  module Provider
    module Vmfusion
      module BoxCommand

        # Type on the console
        def console_type(sequence,type_options={})
          if vnc_enabled?
            vnc_type(sequence,"127.0.0.1",vnc_display_port)
          else
            raise Veewee::Error, "VNC is not enabled"
          end
        end

      end
    end
  end
end
