require 'tempfile'

module Veewee
  module Builder
    module Vmfusion
      
      # This function 'exports' the box based on the definition
      def export_ova
        debug="--X:logToConsole=true --X:logLevel=\"verbose\""
        debug=""
        flags="--compress=9"
        #before exporting the system needs to be shut down
        # otherwise the debug log will show - The specified virtual disk needs repair
        Veewee::Util::Shell.execute("#{fusion_path.shellescape}/ovftool/ovftool.bin #{debug} #{flags} #{vmx_file_path.shellescape} #{@box_name}.ova")
      end
      
    end
  end
end