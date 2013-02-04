module Veewee
  module Provider
    module Vsphere
      module BoxCommand

        # Type on the console
        def console_type(sequence,type_options={})
          enable_vnc unless vnc_enabled?
          if vnc_enabled?
            begin
              vnc_type(sequence,vnc_host,vnc_port)
            rescue Errno::ETIMEDOUT
              # Raise VncError if connectin times out
              raise Veewee::VncError, "Connection to VNC timed out"
            end
          else
            raise Veewee::Error, "VNC is not enabled"
          end
        end

      end
    end
  end
end
