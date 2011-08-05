module Veewee
  module Builder
    module Vmfusion

      def determine_vmrun_cmd
        return "#{fusion_path}/vmrun"
      end   

      def vm_path
        home=ENV['HOME']
        dir="#{home}/Documents/Virtual Machines.localized/#{@box_name}.vmwarevm"
        return dir
      end

      def fusion_path
        dir="/Library/Application Support/VMware Fusion/"
        return dir
      end

      def vmx_file_path
        return "#{vm_path}/#{@box_name}.vmx"
      end

    end
  end
end