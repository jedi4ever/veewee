require 'veewee/provider/core/box'
require 'veewee/provider/core/box/vnc'
require 'veewee/provider/kvm/box/validate_kvm'

module Veewee
  module Provider
    module Kvm
      module BoxCommand
        # Type on the console
        def console_type(sequence,type_options={})
          vnc_port=@connection.servers.all(:name => name).first.vnc_port
          display_port=vnc_port.to_i - 5900
          ui.success "Sending keystrokes to VNC port :#{display_port} - TCP port: #{vnc_port}"
          vnc_type(sequence,"127.0.0.1",display_port)
        end

      end # End Module
    end # End Module
  end # End Module
end # End Module
