module Veewee
  module Builder
    module Vmfusion
      
      def create_vm
        FileUtils.mkdir_p(vm_path)
        current_dir=FileUtils.pwd
        FileUtils.chdir(vm_path)
        aFile = File.new(vmx_file_path, "w")
        aFile.write(vmx_template)
        aFile.close
        FileUtils.chdir(current_dir)
          
      end
      
      def start_vm(mode)
        #mode can be gui or nogui
        Veewee::Util::Shell.execute("#{fusion_path.shellescape}/vmrun -T ws start '#{vmx_file_path}' #{mode}")
      end

      def stop_vm()
        Veewee::Util::Shell.execute("#{fusion_path.shellescape}/vmrun -T ws stop '#{vmx_file_path}' soft")
      end

      def halt_vm()
        Veewee::Util::Shell.execute("#{fusion_path.shellescape}/vmrun -T ws stop '#{vmx_file_path}' hard")
      end
      
    end
  end
end
