module Veewee
  module Provider
    module Virtualbox
      module BoxCommand

        def ssh_options
          build_ssh_options.tap do |options|
            port = definition.ssh_host_port
            if self.exists?
              forward=self.forwarding("guestssh")
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
