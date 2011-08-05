module Veewee
  module Builder
    module Virtualbox
      
      def create_floppy
        # Todo Check for java
        # Todo check output of commands

        # Check for floppy
        unless @definition.floppy_files.nil?
          require 'tmpdir'
          temp_dir=Dir.tmpdir
          @definition.floppy_files.each do |filename|
            full_filename=full_filename=File.join(@environment.definition_dir,@box_name,filename)
            FileUtils.cp("#{full_filename}","#{temp_dir}")
          end
          javacode_dir=File.expand_path(File.join(__FILE__,'..','..','java'))
          floppy_file=File.join(@environment.definition_dir,@box_name,"virtualfloppy.vfd")
          command="java -jar #{javacode_dir}/dir2floppy.jar '#{temp_dir}' '#{floppy_file}'"
          Veewee::Util::Shell.execute("#{command}")



        end
      end
            
      
      def add_floppy_controller
        # Create floppy controller
        unless @definition.floppy_files.nil?
        
          command="#{@vboxcmd} storagectl '#{@box_name}' --name 'Floppy Controller' --add floppy"
          Veewee::Util::Shell.execute("#{command}")
        end
      end
      
      
      def attach_floppy
        unless @definition.floppy_files.nil?
        
        # Attach floppy to machine (the vfd extension is crucial to detect msdos type floppy)
        floppy_file=File.join(@environment.definition_dir,@box_name,"virtualfloppy.vfd")        
        command="#{@vboxcmd} storageattach '#{@box_name}' --storagectl 'Floppy Controller' --port 0 --device 0 --type fdd --medium '#{floppy_file}'"
        Veewee::Util::Shell.execute("#{command}")
        end
      end
    end
  end
end
