require 'erb'

module Veewee
  module Provider
    module Vmfusion
      module BoxCommand
      class ErbBinding < OpenStruct
        def get_binding
          return binding()
        end
      end

      def vmx_template(definition)
        # We only want specific variables for ERB

        data = {
          :cpu_count => definition.cpu_count, :memory_size => definition.memory_size,
          :controller_type => "lsilogic",
          :fusion_os_type => definition.os_type_id,
          :mac_addres => "auto generated",
          :iso_file => "#{File.join(env.config.veewee.iso_dir,definition.iso_file)}",
          :box_name => name,
          :vnc_port => guess_vnc_port
        }

        vars = ErbBinding.new(data)
        template_path=File.join(File.dirname(__FILE__),"template.vmx.erb")
        template=File.open(template_path).readlines.join
        erb = ERB.new(template)
        vars_binding = vars.send(:get_binding)
        result=erb.result(vars_binding)
        return result
      end
    end

  end
end
end
