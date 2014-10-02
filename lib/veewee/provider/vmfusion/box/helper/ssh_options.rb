module Veewee
  module Provider
    module Vmfusion
      module BoxCommand

        # Translate the definition ssh options to ssh options that can be passed to Net::Ssh calls
        def ssh_options
          build_ssh_options
        end

      end
    end
  end
end
