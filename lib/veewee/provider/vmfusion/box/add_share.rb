module Veewee
  module Provider
    module Vmfusion
      module BoxCommand
        # This function 'adds a share' the box based on the definition
        def add_share(share_name, share_path)
          shell_exec("#{(vmrun_cmd).shellescape} -T fusion addSharedFolder #{vmx_file_path.shellescape} '#{share_name}' #{::File.expand_path(share_path).shellescape}")
        end

        def add_share_from_defn
          definition.add_shares.each do |share_name, share_path|
            add_share(share_name, share_path)
          end
        end
      end
    end
  end
end
