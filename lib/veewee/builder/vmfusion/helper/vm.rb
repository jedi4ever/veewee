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
        raw=::Fission::VM.new(name)
        raw.start
      end

      def stop_vm()
        raw=::Fission::VM.new(name)
        raw.stop
      end

      def halt_vm()
        raw=::Fission::VM.new(name)
        raw.halt
      end

    end
  end
end
