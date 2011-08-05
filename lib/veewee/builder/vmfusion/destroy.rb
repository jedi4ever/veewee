module Veewee
  module Builder
    module Vmfusion
      
      def destroy(destroy_options={})
        if is_running?
          raise RuntimeError,"VM is running" unless !destroy_options["force"].nil?
          halt_vm
        end
        
        # TODO: this still fails if the gui is running
        # It's either this, or start the machines in nogui mode
        # Also it needs to unregister from the GUI, not sure how that's gonna work
        destroy_vm(destroy_options)
        destroy_disk(destroy_options)                 

        ## Stop the fusion GUI interface
        #FUSION_PID=$(ps -eo pid,command  |grep -i "/Applications/VMware Fusion.app/Contents/MacOS/vmware"|grep -v grep| sed -e "s/^[ ]*//"|cut -d ' ' -f 1)
        #echo $FUSION_PID
        #kill $FUSION_PID
      end
      
      def destroy_vm(destroy_options={})
        Veewee::Util::Shell.execute("#{fusion_path.shellescape}/vmrun -T ws deleteVM '#{vmx_file_path}'")
      end
      
      def destroy_disk(destroy_option={})
        FileUtils.rm_rf("#{vm_path.shellescape}")
      end
      
	  end
	end
end
