module Veewee
  module Provider
    module Vmfusion
      module BoxCommand

        def vnc_port
           lines=File.readlines(vmx_file_path)
           matches=lines.grep(/^RemoteDisplay.vnc.port/)
           if matches.length==0
              raise Veewee::Error,"No VNC port found, maybe it is not enabled?"
           else
              value=matches.first.split("\"")[1].to_i
              return value
           end
        end

        # This tries to guess a port for the VNC Display
        def guess_vnc_port
          min_port=5920
          max_port=6000
          guessed_port=nil

          for port in (min_port..max_port)
            unless is_tcp_port_open?("127.0.0.1", port)
              guessed_port=port
              break
            end
          end

          if guessed_port.nil?
            env.ui.info "No free VNC port available: tried #{min_port}..#{max_port}"
            raise Veewee::Error, "No free VNC port available: tried #{min_port}..#{max_port}"
          else
            env.ui.info "Found VNC port #{guessed_port} available"
          end

          return guessed_port
        end

        def vnc_display_port
          self.vnc_port - 5900
        end

        def vnc_enabled?
           lines=File.readlines(vmx_file_path)
           matches=lines.grep(/^RemoteDisplay.vnc.enabled/)
           if matches.length==0
              return false
           else
              if matches.first.split("\"")[1].downcase == 'true'
                return true
              else
                return false
              end
           end
        end

      end
    end
  end
end
