module Veewee
  module Provider
    module Vsphere
      module BoxCommand

        # Type on the console
        def console_type(sequence,type_options={})
          enable_vnc unless vnc_enabled?
          if vnc_enabled?
            vnc_type(sequence,vnc_host,vnc_port)
          else
            raise Veewee::Error, "VNC is not enabled"
          end
        end

      end
    end
  end
end
