module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        def winrm_options
          build_winrm_options.tap do |options|
            port=definition.winrm_host_port
            if self.exists?
              forward=self.forwarding("guestwinrm")
              unless forward.nil?
                port=forward[:host_port]
              end
            end
            options[:port] = port
          end
        end

      end
    end
  end
end
